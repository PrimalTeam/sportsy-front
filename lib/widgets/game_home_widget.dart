import 'package:flutter/material.dart';
import 'package:sportsy_front/modules/game_list_struct.dart';

class GameHomeWidget extends StatelessWidget {
  final GameDetails gameDetails;
  const GameHomeWidget({super.key, required this.gameDetails});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border:
            gameDetails.isHost
                ? Border.all(color: Colors.white, width: 3)
                : null,
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
              gameDetails.sportType == "football"
                  ? Icons.sports_soccer
                  : gameDetails.sportType == "basketball"
                  ? Icons.sports_basketball
                  : gameDetails.sportType == "volleyball"
                  ? Icons.sports_volleyball
                  : Icons.question_mark,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Text(gameDetails.gameName),
          Spacer(),
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return Container(
                    height: 200,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          gameDetails.gameName,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text("You participate in this game"),
                        ListTile(
                          leading: Icon(Icons.exit_to_app, color: Colors.red),
                          title: Text('Exit game'),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            icon: Icon(Icons.more_horiz),
          ),
        ],
      ),
    );
  }
}
