<?xml version="1.0" encoding="utf-8"?>
<widget>
    <meta name="widget" version="1.0.0" targetAPI="6.0"/>
    <styles>
        <style parent="root">
            <width>100%</width>
            <height>100%</height>
            <padding>16</padding>
            <background>#000000</background>
            <border-radius>16</border-radius>
        </style>
    </styles>
    <div class="root" style="width:100%;height:100%;padding:16;background:#000000;border-radius:16;">
        <stack style="width:100%;height:100%;">
            <column style="width:100%;height:100%;align-items:center;justify-content:center;">
                <text id="time" style="font-size:32;font-weight:bold;color:#FFFFFF;text-align:center;">
                    {{ time }}
                </text>
                <text id="date" style="font-size:14;color:rgba(255,255,255,0.7);text-align:center;margin-top:4;">
                    {{ date }}
                </text>
            </column>
        </stack>
    </div>
</widget>
