var mapWeeksFunction = function() {
    var parseDate = function(date_string){
        var date_parts = date_string.split("-");
        return new Date(date_parts[0], (date_parts[1]-1), date_parts[2])
    }

    var getMonday = function (date) {

        var now = date? new Date(date) : new Date();
        now.setHours(0,0,0,0);

        var monday = new Date(now);
        monday.setDate(monday.getDate() - monday.getDay() + 1);

        return monday;
    }

    var printDate = function(date) {
        year = date.getFullYear().toString();
        month = (date.getMonth() + 1);
        month = month  >= 10 ? month.toString() : '0' + month.toString();
        day = (date.getDate());
        day = day  >= 10 ? day.toString() : '0' + day.toString();
        return year + '-' +
               month + '-' +
               day;
    }

    var date = parseDate(this.date);
    var week = getMonday(date);
    var key = {
        name: this.name,
        week: printDate(week)
    };

    var value ={
        views: this.views
    }
    emit(key, value);
};

var reduceWeeksFunction = function(key, values) {
    reducedVal = {
        views: 0};

    for (var idx = 0; idx < values.length; idx++) {
        reducedVal.views += values[idx].views;
    }

    return reducedVal;
};

db.views.mapReduce(
    mapWeeksFunction,
    reduceWeeksFunction,
    {
        out: { replace: "tmp_weeks" }
    }
)

var mapMonthAvgFunction = function() {
    var parseDate = function(date_string){
        var date_parts = date_string.split("-");
        return new Date(date_parts[0], (date_parts[1]-1), date_parts[2])
    }

    var date = parseDate(this._id.week);

    var key = {
        name: this._id.name,
        month: date.getMonth()
    };

    var value ={
        views: this.value.views,
        count: 1,
        weeks: [{
            week: this._id.week,
            views: this.value.views
        }]};

    emit(key, value);
};

var reduceMonthAvgFunction = function(key, values) {
    reducedVal = {
        views: 0,
        count: 0,
        weeks: []};

    for (var idx = 0; idx < values.length; idx++) {
        reducedVal.views += values[idx].views;
        reducedVal.count += values[idx].count;
        for(var idx2 = 0; idx2 < values[idx].weeks.length; idx2++){
            reducedVal.weeks.push(values[idx].weeks[idx2]);
        }
    }

    return reducedVal;
};

var finalizeMonthAvgFunction = function (key, reducedVal) {

    reducedVal.avg = reducedVal.views/reducedVal.count;

    return reducedVal;

};

db.tmp_weeks.mapReduce(
    mapMonthAvgFunction,
    reduceMonthAvgFunction,
    {
        out: { replace: "tmp_monthAvg" },
        finalize: finalizeMonthAvgFunction
    }
)

var mapWeeksDiffFunction = function() {

    for(var idx = 0; idx < this.value.weeks.length; idx++){
        var key = {
            name: this._id.name,
            date: this.value.weeks[idx].week
        };

        var value ={
            type: 'weekly',
            diff: this.value.weeks[idx].views - this.value.avg
        }
        emit(key, value);
    }
};

var reduceWeeksDiffFunction = function(key, values) {
    reducedVal = {
        type: '',
        diff: 0
    };

    for (var idx = 0; idx < values.length; idx++) {
        reducedVal.type = values[idx].type;
        reducedVal.diff = values[idx].diff;
    }

    return reducedVal;
};


db.tmp_monthAvg.mapReduce(
    mapWeeksDiffFunction,
    reduceWeeksDiffFunction,
    {
        out: { replace: "tmp_weeksDiff" }
    }
)

var cursor = db.tmp_weeksDiff.find();
var record;
while(cursor.hasNext()) {
    record = cursor.next();
    data = {
        name: record._id.name,
        type: record.value.type,
        diff: record.value.diff,
        valid_date: record._id.date
    }
    db.trends.update({name: record._id.name, type: record.value.type, valid_date: record._id.date},
        data, {upsert: true});
}

db.tmp_weeks.drop();
db.tmp_monthAvg.drop();
db.tmp_weeksDiff.drop();
