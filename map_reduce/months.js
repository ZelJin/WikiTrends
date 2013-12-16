var mapMonthsFunction = function() {
    var parseDate = function(date_string){
        var date_parts = date_string.split("-");
        return new Date(date_parts[0], (date_parts[1]-1), date_parts[2])
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
    date.setDate(1);
    var key = {
        name: this.name,
        month: printDate(date)
    };

    var value ={
        views: this.views
    }
    emit(key, value);
};

var reduceMonthsFunction = function(key, values) {
    reducedVal = {
        views: 0};

    for (var idx = 0; idx < values.length; idx++) {
        reducedVal.views += values[idx].views;
    }

    return reducedVal;
};

db.views.mapReduce(
    mapMonthsFunction,
    reduceMonthsFunction,
    {
        out: { replace: "tmp_months" }
    }
)

var mapHalfyearAvgFunction = function() {
    var parseDate = function(date_string){
        var date_parts = date_string.split("-");
        return new Date(date_parts[0], (date_parts[1]-1), date_parts[2])
    }

    var date = parseDate(this._id.month);

    var key = {
        name: this._id.name,
        halfyear: date.getMonth() > 5 ? 1 : 0
    };

    var value ={
        views: this.value.views,
        count: 1,
        months: [{
            month: this._id.month,
            views: this.value.views
        }]};

    emit(key, value);
};

var reduceHalfyearAvgFunction = function(key, values) {
    reducedVal = {
        views: 0,
        count: 0,
        months: []};

    for (var idx = 0; idx < values.length; idx++) {
        reducedVal.views += values[idx].views;
        reducedVal.count += values[idx].count;
        for(var idx2 = 0; idx2 < values[idx].months.length; idx2++){
            reducedVal.months.push(values[idx].months[idx2]);
        }
    }

    return reducedVal;
};

var finalizeHalfyearAvgFunction = function (key, reducedVal) {

    reducedVal.avg = reducedVal.views/reducedVal.count;

    return reducedVal;

};

db.tmp_months.mapReduce(
    mapHalfyearAvgFunction,
    reduceHalfyearAvgFunction,
    {
        out: { replace: "tmp_halfyearAvg" },
        finalize: finalizeHalfyearAvgFunction
    }
)

var mapMonthsDiffFunction = function() {

    for(var idx = 0; idx < this.value.months.length; idx++){
        var key = {
            name: this._id.name,
            date: this.value.months[idx].month
        };

        var value ={
            type: 'monthly',
            diff: this.value.months[idx].views - this.value.avg
        }
        emit(key, value);
    }
};

var reduceMonthsDiffFunction = function(key, values) {
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


db.tmp_halfyearAvg.mapReduce(
    mapMonthsDiffFunction,
    reduceMonthsDiffFunction,
    {
        out: { replace: "tmp_monthsDiff" }
    }
)

var cursor = db.tmp_monthsDiff.find();
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

db.tmp_months.drop();
db.tmp_halfyearAvg.drop();
db.tmp_monthsDiff.drop();
