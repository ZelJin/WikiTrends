var mapWeekAvgFunction = function() {
    var parseDate = function(date_string){
        var date_parts = date_string.split("-");
        return new Date(date_parts[0], (date_parts[1]-1), date_parts[2])
    }

    Date.prototype.getWeek = function(){
        var first_jan = new Date(this.getFullYear(), 0, 1);
        return Math.ceil((((this-first_jan)/86400000)+first_jan.getDay()+1)/7)
    }
    var date = parseDate(this.date);

    var key = {
        name: this.name,
        week: date.getWeek()
    };

    var value ={
        views: this.views,
        count: 1,
        days: [{
            date: this.date,
            views: this.views
        }]};
    emit(key, value);
};

var reduceWeekAvgFunction = function(key, values) {
    reducedVal = {
        views: 0,
        count: 0,
        days: []};

    for (var idx = 0; idx < values.length; idx++) {
        reducedVal.views += values[idx].views;
        reducedVal.count += values[idx].count;
        for(var idx2 = 0; idx2 < values[idx].days.length; idx2++){
            reducedVal.days.push(values[idx].days[idx2]);
        }
    }

    return reducedVal;
};

var finalizeWeekAvgFunction = function (key, reducedVal) {

    reducedVal.avg = reducedVal.views/reducedVal.count;

    return reducedVal;

};

db.views.mapReduce(
    mapWeekAvgFunction,
    reduceWeekAvgFunction,
    {
        out: { replace: "tmp_weekAvg" },
        finalize: finalizeWeekAvgFunction
    }
)

var mapDaysDiffFunction = function() {

    for(var idx = 0; idx < this.value.days.length; idx++){
        var key = {
            name: this._id.name,
            date: this.value.days[idx].date
        };

        var value ={
            type: 'daily',
            diff: this.value.days[idx].views - this.value.avg
        }
        emit(key, value);
    }
};

var reduceDaysDiffFunction = function(key, values) {
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

db.tmp_weekAvg.mapReduce(
    mapDaysDiffFunction,
    reduceDaysDiffFunction,
    {
        out: { replace: "tmp_daysDiff" }
    }
)

var cursor = db.tmp_daysDiff.find();
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

db.tmp_weekAvg.drop();
db.tmp_daysDiff.drop();
