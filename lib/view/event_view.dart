import 'package:fenix/model/event.dart';
import 'package:flutter/material.dart';

class EventWidget {
  Container getEvent(
    String pathToImage,
    Event event,
    bool borderShow,
  ) {
    Border border = Border.all(color: Colors.white);
    if (borderShow) {
      border = Border.all(color: Color(0xFFD9D9D9));
    }

    return Container(
      width: 351,
      height: 113,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Color(0xFFFFFFFF),
        border: border,
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
                          event.title,
                          style: TextStyle(color: Color(0xBF484C52)),
                        ),
                      ),
                      SizedBox(
                        width: 205,
                        child: Text(
                          event.startDate,
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
