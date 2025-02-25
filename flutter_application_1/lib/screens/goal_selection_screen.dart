import 'package:flutter/material.dart';
import '../common/color_extension.dart';
import '../common/common_widgets.dart';
import 'profile_screen.dart';


class GoalSelectionScreen extends StatefulWidget {
  const GoalSelectionScreen({Key? key}) : super(key: key);

  @override
  _GoalSelectionScreenState createState() => _GoalSelectionScreenState();
}

class _GoalSelectionScreenState extends State<GoalSelectionScreen> {
  final List<String> goals = ["Ganar Músculo", "Perder Peso", "Flexibilidad"];
  final Set<String> selectedGoals = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorExtension.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                "Elige tu Objetivo",
                style: TextStyle(
                  color: ColorExtension.textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Personaliza tu experiencia según tu meta",
                style: TextStyle(
                  color: ColorExtension.grayColor,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 30),
              ...goals.map((goal) => GestureDetector(
                    onTap: () {
                      setState(() {
                        if (selectedGoals.contains(goal)) {
                          selectedGoals.remove(goal);
                        } else {
                          selectedGoals.add(goal);
                        }
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      decoration: BoxDecoration(
                        color: selectedGoals.contains(goal)
                            ? ColorExtension.primaryColor.withOpacity(0.8)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selectedGoals.contains(goal)
                              ? ColorExtension.primaryColor
                              : ColorExtension.grayColor,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            goal,
                            style: TextStyle(
                              color: selectedGoals.contains(goal)
                                  ? Colors.white
                                  : ColorExtension.textColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (selectedGoals.contains(goal))
                            Icon(Icons.check_circle, color: Colors.white)
                        ],
                      ),
                    ),
                  )),
              const SizedBox(height: 40),
              PrimaryButton(
                text: "Continuar",
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
