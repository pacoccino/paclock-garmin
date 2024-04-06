import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
using Toybox.Time;
using Toybox.SensorHistory;
using Toybox.Time.Gregorian;
import Toybox.Position;
import Toybox.Weather;
import Toybox.WatchUi;

class paclockView extends WatchUi.WatchFace {

    private var _iconFont as FontResource?;
    private var _screenCenterPoint as Array<Number>?;

    private const MIN_PER_DAY = 24*60;
    private const TEXT_JUSTIFY = Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER;

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        //setLayout(Rez.Layouts.WatchFace(dc));
        _iconFont = WatchUi.loadResource($.Rez.Fonts.id_icon_fonts) as FontResource;
        _screenCenterPoint = [dc.getWidth() / 2, dc.getHeight() / 2] as Array<Number>;

    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    function formatTime(time as Gregorian.Info) as String {
        return Lang.format("$1$:$2$", [time.hour, time.min.format("%02d")]);
    }
    function pad(n as Number) as String {
        return n.format("%02d");
    }

    function timeToAngle(time as Gregorian.Info) as Number {
        var timeMinutes = time.min + time.hour * 60;
        return (timeMinutes.toFloat() / MIN_PER_DAY * 360).toNumber();
    }

    function drawSolarClock(dc as Dc) {
        var time = Time.now();
        var timeGregorian = Gregorian.info(time, Time.FORMAT_MEDIUM);
        var positionInfo = Position.getInfo();

        var midnightOffset = 90;
        var thickness = 15;
        var nowAngle = timeToAngle(timeGregorian) + midnightOffset;
        var radius = (_screenCenterPoint[1] > _screenCenterPoint[0]) ? _screenCenterPoint[0] : _screenCenterPoint[1];

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        
        // Sun icon
        dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_screenCenterPoint[0] + 15, _screenCenterPoint[1] - 53, _iconFont, "q", TEXT_JUSTIFY);

        var sunrise = Weather.getSunrise(positionInfo.position, time);
        var sunset = Weather.getSunset(positionInfo.position, time);

        var sunReady = sunrise != null && sunset != null;

        if(sunReady) {
            var sunriseGreg = Gregorian.info(sunrise, Time.FORMAT_MEDIUM);
            var sunsetGreg = Gregorian.info(sunset, Time.FORMAT_MEDIUM);
            var nextSunType = 0;
            if(time.lessThan(sunset) && time.greaterThan(sunrise)) {
                nextSunType = 2;
            } else {
                nextSunType = 1;
            }


            var setAngle = timeToAngle(sunsetGreg) + midnightOffset;
            var riseAngle = timeToAngle(sunriseGreg) + midnightOffset;

            // solar arc
            dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
            drawArc(dc, _screenCenterPoint[0], _screenCenterPoint[1], radius-thickness, radius, riseAngle, setAngle);
            dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
            drawArc(dc, _screenCenterPoint[0], _screenCenterPoint[1], radius-thickness,  radius, setAngle-360, riseAngle);

            // Sun rise/set
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            if(nextSunType == 1) {
                dc.drawText(_screenCenterPoint[0] + 54, _screenCenterPoint[1] - 50, Graphics.FONT_TINY, formatTime(sunriseGreg), TEXT_JUSTIFY);
            } else if (nextSunType == 2) {
                dc.drawText(_screenCenterPoint[0] + 54, _screenCenterPoint[1] - 50, Graphics.FONT_TINY, formatTime(sunsetGreg), TEXT_JUSTIFY);
            }
        } else {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(_screenCenterPoint[0] + 54, _screenCenterPoint[1] - 50, Graphics.FONT_TINY, "--:--", TEXT_JUSTIFY);
        }
    
        // Now hand
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        drawArc(dc, _screenCenterPoint[0], _screenCenterPoint[1], radius-thickness,  radius, nowAngle-2, nowAngle+2);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        drawArc(dc, _screenCenterPoint[0], _screenCenterPoint[1], radius-thickness,  radius, nowAngle-1, nowAngle+1);

        // Texts

        // Hour
        dc.drawText(_screenCenterPoint[0]-20, _screenCenterPoint[1], Graphics.FONT_NUMBER_HOT, pad(timeGregorian.hour), Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(_screenCenterPoint[0]-6, _screenCenterPoint[1], Graphics.FONT_NUMBER_HOT, pad(timeGregorian.min), Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        if(timeGregorian.sec%2 == 0) {
            dc.drawText(_screenCenterPoint[0]-14, _screenCenterPoint[1]-2, Graphics.FONT_NUMBER_MEDIUM, ":", TEXT_JUSTIFY);
        }
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_screenCenterPoint[0]+93, _screenCenterPoint[1], Graphics.FONT_TINY, pad(timeGregorian.sec), TEXT_JUSTIFY);
       
        // Battery
        var systemStats = System.getSystemStats();  
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_screenCenterPoint[0]-10, _screenCenterPoint[1] - 98, _iconFont, "S", TEXT_JUSTIFY);
        dc.drawText(_screenCenterPoint[0] + 5, _screenCenterPoint[1] - 104, Graphics.FONT_XTINY, Lang.format("$1$ j", [systemStats.batteryInDays.format("%i")]), Graphics.TEXT_JUSTIFY_LEFT);
       
        // Lines
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(_screenCenterPoint[0], _screenCenterPoint[1] - 36, _screenCenterPoint[0], _screenCenterPoint[1] - 62);

        // Date
        var dateString = Lang.format("$1$ $2$", [timeGregorian.day_of_week, timeGregorian.day]);
        dc.drawText(_screenCenterPoint[0]-35, _screenCenterPoint[1] - 50, Graphics.FONT_TINY, dateString, TEXT_JUSTIFY);

       // Temperature
        var temperatureIter = SensorHistory.getTemperatureHistory({});
        var lastTemp = temperatureIter.next().data;
        if(lastTemp != null) {
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            dc.drawText(_screenCenterPoint[0]-10, _screenCenterPoint[1] + 55, _iconFont, "X", TEXT_JUSTIFY);
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(_screenCenterPoint[0]+3, _screenCenterPoint[1] + 43, Graphics.FONT_TINY, Lang.format("$1$°", [lastTemp.format("%i")]), Graphics.TEXT_JUSTIFY_LEFT);
        }

        // Heart rate
        var heartRateIter = SensorHistory.getHeartRateHistory({});
        var lastHR = heartRateIter.next().data;
        if(lastHR != null) {
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            dc.drawText(_screenCenterPoint[0]-10, _screenCenterPoint[1] + 80, _iconFont, "m", TEXT_JUSTIFY);
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(_screenCenterPoint[0]+3, _screenCenterPoint[1] + 68, Graphics.FONT_TINY, lastHR, Graphics.TEXT_JUSTIFY_LEFT);
        }
    }

    function drawArc(dc as Dc, centerX as Number, centerY as Number, startRadius as Number, endRadius as Number, startAngle as Number, endAngle as Number) {

        /*for(var i = startAngle; i < endAngle; i += 0.5) {
            var ci = Math.cos(Math.toRadians(i));
            var si = Math.sin(Math.toRadians(i));
            var fromx = centerX + startRadius * ci;
            var fromy = centerY + startRadius * si;
            var tox = centerX + endRadius * ci;
            var toy = centerY + endRadius * si;
            dc.drawLine(fromx, fromy, tox, toy);
        }*/

        for(var i = startRadius; i < endRadius; i += 1) {
            dc.drawArc(centerX, centerY, i, Graphics.ARC_CLOCKWISE, -startAngle, -endAngle);
        }
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        /*
        if(dc has :setAntiAlias) {
            dc.setAntiAlias(true);
        }
        */
        drawSolarClock(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
    }

}
