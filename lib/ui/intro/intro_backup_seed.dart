import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nano_core/flutter_nano_core.dart';
import 'package:kalium_wallet_flutter/appstate_container.dart';
import 'package:kalium_wallet_flutter/localization.dart';
import 'package:kalium_wallet_flutter/colors.dart';
import 'package:kalium_wallet_flutter/kalium_icons.dart';
import 'package:kalium_wallet_flutter/styles.dart';
import 'package:kalium_wallet_flutter/model/vault.dart';
import 'package:kalium_wallet_flutter/ui/util/ui_util.dart';
import 'package:kalium_wallet_flutter/util/nanoutil.dart';
import 'package:kalium_wallet_flutter/util/clipboardutil.dart';

class IntroBackupSeedPage extends StatefulWidget {
  @override
  _IntroBackupSeedState createState() => _IntroBackupSeedState();
}

class _IntroBackupSeedState extends State<IntroBackupSeedPage> {
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  String _seed = "";
  TextStyle _seedTapStyle = KaliumStyles.TextStyleSeed;
  var _seedCopiedColor;
  Timer _seedCopiedTimer;

  @override
  void initState() {
    super.initState();
        
    Vault.inst.setSeed(NanoSeeds.generateSeed()).then((result) {
      // Update wallet
      StateContainer.of(context).updateWallet(address:NanoUtil.seedToAddress(result));
      StateContainer.of(context).requestUpdate();
      // Update local state
      setState(() {
        _seed = result;
        _seedTapStyle = KaliumStyles.TextStyleSeed;
        _seedCopiedColor = Colors.transparent;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light
        .copyWith(statusBarIconBrightness: Brightness.light));

    // Back button pressed
    Future<bool> _onWillPop() async {
      // Delete seed
      await Vault.inst.deleteAll();
      // Delete any shared prefs
      await Vault.inst.deleteAll();
      return true;
    }

    return new WillPopScope(
      onWillPop:_onWillPop,
      child: new Scaffold(
        key: _scaffoldKey,
        backgroundColor: KaliumColors.background,
        body: LayoutBuilder(
          builder: (context, constraints) => Column(
                children: <Widget>[
                  //A widget that holds the header, the paragraph, the seed, "seed copied" text and the back button
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(
                          vertical: MediaQuery.of(context).size.height * 0.075),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              // Back Button
                              Container(
                                margin: EdgeInsets.only(left: 20),
                                height: 50,
                                width: 50,
                                child: FlatButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(50.0)),
                                    padding: EdgeInsets.all(0.0),
                                    child: Icon(KaliumIcons.back,
                                        color: KaliumColors.text, size: 24)),
                              ),
                            ],
                          ),
                          // The header
                          Container(
                            margin: EdgeInsets.only(top: 15.0, left: 50),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  KaliumLocalization.of(context).seed,
                                  style: KaliumStyles.TextStyleHeaderColored,
                                ),
                              ],
                            ),
                          ),
                          // The paragraph
                          Container(
                            margin:
                                EdgeInsets.only(left: 50, right: 50, top: 15.0),
                            alignment: Alignment.centerLeft,
                            child: Text(
                                KaliumLocalization.of(context).seedBackupInfo,
                                style: KaliumStyles.TextStyleParagraph),
                          ),
                          Container(
                            // A gesture detector to decide if the is tapped or not
                            child: new GestureDetector(
                                onTap: () {
                                  Clipboard.setData(
                                      new ClipboardData(text: _seed));
                                  ClipboardUtil.setClipboardClearEvent();
                                  setState(() {
                                    _seedTapStyle = KaliumStyles.TextStyleSeedGreen;
                                    _seedCopiedColor = KaliumColors.success;
                                  });
                                  if (_seedCopiedTimer != null) {
                                    _seedCopiedTimer.cancel();
                                  }
                                  _seedCopiedTimer = new Timer(
                                      const Duration(milliseconds: 800), () {
                                    setState(() {
                                      _seedTapStyle = KaliumStyles.TextStyleSeed;
                                      _seedCopiedColor = Colors.transparent;
                                    });
                                  });
                                },
                                // The seed
                                child: new Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 25.0, vertical: 15),
                                  margin: EdgeInsets.only(top: 25),
                                  decoration: BoxDecoration(
                                    color: KaliumColors.backgroundDark,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child:
                                    UIUtil.threeLineSeedText(_seed, textStyle: _seedTapStyle),    
                                )),
                          ),
                          // "Seed copied to Clipboard" text that appaears when seed is tapped
                          Container(
                            margin: EdgeInsets.only(top: 5),
                            child: Text(KaliumLocalization.of(context).seedCopied,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: _seedCopiedColor,
                                  fontFamily: 'NunitoSans',
                                  fontWeight: FontWeight.w600,
                                )),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Next Screen Button 
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(bottom: 30, right: 30),
                        height: 50,
                        width: 50,
                        child: FlatButton(
                            splashColor: KaliumColors.primary30,
                            highlightColor: KaliumColors.primary15,
                            onPressed: () {
                              Navigator.of(context).pushNamed('/intro_backup_confirm');
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50.0)),
                            padding: EdgeInsets.all(0.0),
                            child: Icon(KaliumIcons.forward,
                                color: KaliumColors.primary, size: 50)),
                      ),
                    ],
                  ),
                ],
              ),
        ),
      )
    );
  }
}
