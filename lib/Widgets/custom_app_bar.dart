import 'package:flutter/material.dart';
import 'package:project/Constants/app_colors.dart';
import 'package:project/Models/user_model.dart';

class CustomAppBar extends StatelessWidget {
  final UserModel userModel;

  const CustomAppBar({Key? key, required this.userModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.25,
      color: AppColors.profileBackground,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 60.0,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.account_circle, size: 120.0, color: Colors.black,)
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            Text(
              '${userModel.firstName ?? 'No'} ${userModel.lastName ?? 'Name'}',
              style: const TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
