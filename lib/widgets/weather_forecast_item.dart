import 'package:flutter/material.dart';

class HourlyForecastItem extends StatelessWidget {
  final IconData icon;
  final String time;
  final String temperature;
  final Color iconColor;
  final Color shadowColor;
  const HourlyForecastItem({super.key, required this.icon, required this.time, required this.temperature,required this.iconColor, required this.shadowColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      child: Card(
        elevation: 5,
        shadowColor: shadowColor,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(time,style: const TextStyle(fontSize: 16,fontWeight: FontWeight.bold),maxLines: 1,overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              Icon(icon,size: 32,color: iconColor),
              const SizedBox(height: 8),
              Text(temperature),
            ],
          ),
        ),
      ),
    );
  }
}