import 'package:flutter/material.dart';
import 'package:sportsy_front/custom_colors.dart';
import 'package:sportsy_front/dto/get_room_dto.dart';
import 'package:sportsy_front/screens/game_page.dart';

class GameHomeWidget extends StatelessWidget {
  final GetRoomDto gameDetails;
  const GameHomeWidget({super.key, required this.gameDetails});

  @override
  Widget build(BuildContext context) {
    
    return 
    GestureDetector(
      onTap: ()  {Navigator.push(context, MaterialPageRoute(builder: (context) => GamePage(gameDetails: gameDetails) ),);},
    child: Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border:
            gameDetails.role == "admin"
             ? Border.all(color: Colors.white, width: 3)
             : null,
        color: AppColors.primary,
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
              gameDetails.icon == "football"
                  ? Icons.sports_soccer
                  : gameDetails.icon == "basketball"
                  ? Icons.sports_basketball
                  : gameDetails.icon == "volleyball"
                  ? Icons.sports_volleyball
                  : Icons.question_mark,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Text(gameDetails.name),
          Spacer(),
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return Container(
                    height: 250,
                    color: AppColors.primary,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          gameDetails.name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text("You participate in this game"),
                        ListTile(
                          leading: Icon(Icons.exit_to_app, color: AppColors.accent),
                          title: Text('Exit game', style: TextStyle(color: Colors.red),),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.edit, color: AppColors.accent),
                          title: Text('Edit', style: TextStyle(color: Colors.white,)),
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
    ),
    );
  }
}
