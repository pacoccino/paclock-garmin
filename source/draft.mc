/*
    function getData() {
        var time = Time.now();
        var timeGregorian = Gregorian.info(time, Time.FORMAT_MEDIUM);

        var activity = ActivityMonitor.getInfo();
        var systemStats = System.getSystemStats();  
        var positionInfo = Position.getInfo();
        var heartRateIter = SensorHistory.getHeartRateHistory({});
        var oxygenSaturationIter = SensorHistory.getOxygenSaturationHistory({});
        var temperatureIter = SensorHistory.getTemperatureHistory({});
        var bodyBatteryIter = SensorHistory.getBodyBatteryHistory({});
        var stressIter = SensorHistory.getStressHistory({});

        var data = {};
        data["now"] = timeGregorian;
        data["altitude"] = positionInfo.altitude;
        data["battPercent"] = systemStats.battery;
        data["battDays"] = systemStats.batteryInDays;
        data["batteryCharging"] = systemStats.charging;
        data["activeMinutes"] = activity.activeMinutesDay;
        data["floorsClimbed"] = activity.floorsClimbed;
        data["heartRate"] = heartRateIter.next().data;
        data["oxygenSaturation"] = oxygenSaturationIter.next().data;
        data["temperature"] = temperatureIter.next().data;
        data["bodyBattery"] = bodyBatteryIter.next().data;
        //data["stress"] = stressIter.next().data;

        if(positionInfo.position != null) {
            var sunrise = Weather.getSunrise(positionInfo.position, time);
            var sunset = Weather.getSunset(positionInfo.position, time);
            data[:sunrise] = Gregorian.info(sunrise, Time.FORMAT_MEDIUM);
            data["sunset"] = Gregorian.info(sunset, Time.FORMAT_MEDIUM);
            if(time.lessThan(sunset) && time.greaterThan(sunrise)) {
                data["nextSunType"] = "SET";
            } else {
                data["nextSunType"] = "RISE";
            }
        }

        System.println(data);
        return data;
    } 
*/