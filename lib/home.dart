import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:staking_token/stake_utils.dart';
import 'package:staking_token/token_utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  StakeUtils stakeUtils = StakeUtils();
  TokenUtils tokenUtils = TokenUtils();
  var myBalance = 0.0;
  var myStaking = 0.0;
  var minStake = 0.0;
  var maxStake = 0.0;
  var totalStaked = 0.0;
  var apr = 0.0;

  TextEditingController stake = TextEditingController();
  TextEditingController unstake = TextEditingController();

  void loadAll() {
    tokenUtils.getMyBalance().then((value) {
      setState(() {
        myBalance = value;
      });
    });
    stakeUtils.myStaking().then((value) {
      setState(() {
        myStaking = value;
      });
    });
    stakeUtils.minStake().then((value) {
      setState(() {
        minStake = value;
      });
    });
    stakeUtils.maxStake().then((value) {
      setState(() {
        maxStake = value;
      });
    });
    stakeUtils.totalStaked().then((value) {
      setState(() {
        totalStaked = value;
      });
    });
    stakeUtils.apr().then((value) {
      setState(() {
        apr = value;
      });
    });
  }

  var isApproved = false;

  @override
  void initState() {
    stake = TextEditingController();
    unstake = TextEditingController();
    stakeUtils.initial();
    tokenUtils.initial();
    loadAll();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  var isMinning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  isMinning == true
                      ? Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 20),
                          decoration: BoxDecoration(
                            color: Colors.orange[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                height: 15,
                                width: 15,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 5),
                              Text("Minning process.."),
                            ],
                          ),
                        )
                      : SizedBox(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () {
                          loadAll();
                        },
                        icon: Icon(Icons.refresh),
                      ),
                      SizedBox(width: 10),
                      Text(
                        "My Balance: $myBalance IZR",
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(10),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    "Total Staked APR: $apr %",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Text(
                    "$totalStaked IZR",
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text("Min Staking : $minStake IZR"),
                  const SizedBox(width: 10),
                  Text("Max Staking : $maxStake IZR"),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(10),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.purple[900],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  const Text(
                    "My Staked",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 18),
                  ),
                  Text(
                    "$myStaking IZR",
                    style: const TextStyle(
                      fontSize: 30,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[400],
                    ),
                    onPressed: () {
                      setState(() {
                        isMinning = true;
                      });
                      stakeUtils.claimReward().then((value) {
                        setState(() {
                          isMinning = false;
                        });
                      });
                    },
                    child: Text(
                      "Claim Reward",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 50,
                  width: 200,
                  child: TextField(
                    controller: stake,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      hintText: "Jumlah Token",
                    ),
                  ),
                ),
                stakeButton(isApproved == true ? "STAKE" : "APPROVE", () {
                  setState(() {
                    isMinning = true;
                  });
                  if (isApproved == false) {
                    tokenUtils
                        .approval((int.parse(stake.text) * pow(10, 18)).toInt())
                        .then((value) {
                      setState(() {
                        isApproved = true;
                        isMinning = false;
                      });
                    });
                  } else {
                    stakeUtils.stake(int.parse(stake.text)).then((value) {
                      setState(() {
                        isApproved = false;
                        isMinning = false;
                      });
                    });
                  }
                }),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 50,
                  width: 200,
                  child: TextField(
                    controller: unstake,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      hintText: "Jumlah Token",
                    ),
                  ),
                ),
                stakeButton("UNSTAKE", () {
                  setState(() {
                    isMinning = true;
                  });
                  stakeUtils.unstake(int.parse(unstake.text)).then((value) {
                    setState(() {
                      isMinning = false;
                    });
                  });
                })
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget stakeButton(String? title, VoidCallback? onTap) => Container(
      width: 150,
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange[300],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: onTap,
        child: Text(
          "$title",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
