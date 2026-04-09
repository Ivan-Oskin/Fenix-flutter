import 'package:flutter/material.dart';

class EventWidget {
  Container getEvent(
    String pathToImage,
    String information,
    String time,
    String date,
  ) {
    return Container(
      width: 351,
      height: 113,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      child: Center(
        child: SizedBox(
          width: 320,
          child: Row(
            spacing: 20,
            children: [
              SizedBox(
                width: 90,
                height: 90,
                child: Center(child: Image.asset(pathToImage)),
              ),
              Expanded(
                child: SizedBox(
                  width: 195,
                  height: 90,
                  child: Column(
                    spacing: 10,
                    children: [
                      SizedBox(
                        width: 205,
                        child: Text(
                          information,
                          style: TextStyle(color: Color(0xBF484C52)),
                        ),
                      ),
                      SizedBox(
                        width: 205,
                        child: Text(
                          "$time    $date",
                          textAlign: TextAlign.left,
                          style: TextStyle(color: Color(0xFF484C52)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
