import 'package:kakao_flutter_sdk/link.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

class KakaoShareManager {
  static final KakaoShareManager _manager = KakaoShareManager._internal();

  factory KakaoShareManager() {
    return _manager;
  }

  KakaoShareManager._internal() {
    // 초기화 코드
  }

  void initializeKakaoSDK() {
    String kakaoAppKey = "49db......";
    KakaoContext.clientId = kakaoAppKey;
  }

  Future<bool> isKakaotalkInstalled() async {
    bool installed = await isKakaoTalkInstalled();
    return installed;
  }

  void shareMyCode(String code) async {
    try {
      var dynamicLink = await _getDynamicLink(code);
      var template = _getTemplate(dynamicLink, code);
      var uri = await LinkClient.instance.defaultWithTalk(template);
      await LinkClient.instance.launchKakaoTalk(uri);
    } catch (error) {
      print(error.toString());
    }
  }

  Future<Uri> _getDynamicLink(String code) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://bibletree.page.link',
      link: Uri.parse('https://bibletree.page.link/join_family?code=${code}'),
      androidParameters: AndroidParameters(
        packageName: 'com.example.bible_tree',
        minimumVersion: 1,
      ),
      // iosParameters: IosParameters(
      //   bundleId: 'com.jinny.onionFamily',
      //   minimumVersion: '1.0',
      //   appStoreId: '1540106955',
      // )
    );

    Uri dynamicUrl = await parameters.buildUrl();
    return dynamicUrl;
  }

  DefaultTemplate _getTemplate(Uri dynamicLink, String code) {
    String title = "초대 코드: ${code}";

    Uri imageLink = Uri.parse(
        "https://user-images.githubusercontent.com/9502063/98914845-7c4a2000-250c-11eb-8ea8-e71563a96c69.png");

    Link link = Link(mobileWebUrl: dynamicLink);

    Content content = Content(title, imageLink, link, imageHeight: 300);

    FeedTemplate template =
        FeedTemplate(content, buttons: [Button("초대 수락하기", link)]);

    return template;
  }
}
