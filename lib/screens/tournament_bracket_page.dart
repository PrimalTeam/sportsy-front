import 'package:flutter/material.dart';
import 'package:sportsy_front/widgets/app_bar.dart';


class TournamentBracketPage extends StatelessWidget {
  TournamentBracketPage({super.key});
  final List<List<String>> bracket = [
    // Runda 1 (ćwierćfinały)
    ['Gracz 1 vs Gracz 2', 'Gracz 3 vs Gracz 4', 'Gracz 5 vs Gracz 6', 'Gracz 7 vs Gracz 8'],
    // Runda 2 (półfinały)
    ['Zwycięzca 1 vs Zwycięzca 2', 'Zwycięzca 3 vs Zwycięzca 4'],
    // Finał
    ['Zwycięzca półfinału 1 vs Zwycięzca półfinału 2'],
  ];



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: "Drabinka Turniejowa"),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(bracket.length, (roundIndex) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(bracket[roundIndex].length, (matchIndex) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 3,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      width: 160,
                      child: Center(
                        child: Text(
                          bracket[roundIndex][matchIndex],
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ),
      ),
    );
  }
}
