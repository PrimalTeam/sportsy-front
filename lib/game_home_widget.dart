import 'package:flutter/material.dart';

class GameHomeWidget extends StatelessWidget {
  final bool isHost;
  final String gameName;
  final String sportType;
  const GameHomeWidget({
    super.key,
    required this.isHost,
    required this.gameName,
    required this.sportType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: isHost ? Border.all(color: Colors.white, width: 3) : null,
        color: Color(0xff283963),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xff130f34),
            ),
            child: Icon(
              sportType == "football"
                  ? Icons.sports_soccer
                  : sportType == "basketball"
                  ? Icons.sports_basketball
                  : sportType == "volleyball"
                  ? Icons.sports_volleyball
                  : Icons.question_mark,
              color: Colors.white,
            ),
          ),
          Text(gameName),
        ],
      ),
    );
  }
}
