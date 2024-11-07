import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import '../data/global_data.dart';
import 'ApiProvider.dart';

bool isFirebaseCheck = false;
bool isLoadFirebase = false;
//Firebase관련 class
class FirebaseNotifications {
  static String _fcmToken = '';

  static bool isAlarm = false;

  static String get getFcmToken => _fcmToken;

  void setFcmToken (String token) {
    _fcmToken = token;
    isFirebaseCheck = false;
  }

  FirebaseNotifications();

  void setUpFirebase() {
    if(isFirebaseCheck == false){
      isFirebaseCheck = true;
    }else{
      return;
    }

    Future.microtask(() async {
      await FirebaseMessaging.instance.requestPermission(sound: true, badge: true, alert: true, provisional: false);
      return FirebaseMessaging.instance;
    }) .then((_) async{
      if(_fcmToken == ''){
        _fcmToken = (await _.getToken())!;
        var res = await ApiProvider().post('/Fcm/Token/Save', jsonEncode({
          "userID" : GlobalData.loginUser.id,
          "token" : _fcmToken,
          "isParent" : GlobalData.isParents
        }));

        if(res != null){
          FirebaseNotifications.isAlarm = res['Alarm'] ?? true;
        }
      }
      return;
    });
  }

  showNotification(Map<String, dynamic> msg){
  }

  void setSubScriptionToTopic(String topic){
    FirebaseMessaging.instance.subscribeToTopic(topic);
  }

  void setUnSubScriptionToTopic(String topic){
    FirebaseMessaging.instance.unsubscribeFromTopic(topic);
  }

  static void setSubScriptionToTopicClear(){

  }

  static void globalSetSubScriptionToTopic(String topic){
    FirebaseMessaging.instance.subscribeToTopic(topic);
  }

  static void globalSetUnSubScriptionToTopic(String topic){
    FirebaseMessaging.instance.unsubscribeFromTopic(topic);
  }
}