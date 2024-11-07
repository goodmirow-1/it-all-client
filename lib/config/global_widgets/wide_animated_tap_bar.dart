import 'package:flutter/material.dart';
import 'package:itall_app/config/constants.dart';
import 'package:itall_app/config/global_widgets/global_widget.dart';
import '../s_text_style.dart';
import 'package:get/get.dart';

class WideAnimatedTapBar extends StatelessWidget {
  WideAnimatedTapBar({Key? key, required this.barIndex, required this.listTabItemTitle, required this.listTabItemWidth, required this.onPageChanged, required this.bottomLineWidth}) : super(key: key);

  final int barIndex;
  final List<String> listTabItemTitle; //탭 이름 리스트
  final List<double> listTabItemWidth; //탭 width 리스트
  final Function(int index) onPageChanged;
  final double bottomLineWidth;

  static const Duration duration = Duration(milliseconds: 400);
  static const Curve curve = Curves.fastOutSlowIn;

  late final double leftPadding;

  @override
  Widget build(BuildContext context) {
    final double itemWidth = Get.width / listTabItemTitle.length;
    leftPadding = itemWidth * barIndex + (itemWidth / 2 - bottomLineWidth / 2);

    return Container(
      height: 48 * sizeUnit,
      color: iaColorBlack,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Row(
              children: List.generate(
                  listTabItemTitle.length,
                  (index) => InkWell(
                    onTap: () => onPageChanged(index),
                    child: SizedBox(
                      width: (Get.width / listTabItemTitle.length),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Text(
                          listTabItemTitle[index],
                          style: STextStyle.headline5().copyWith(
                            fontWeight: barIndex == index ? FontWeight.bold : FontWeight.w500,
                            color: barIndex == index ? Colors.white : iaColorDarkGrey,
                          ),
                        ),
                      ),
                    ),
                  )),
            ),
          ),
          SizedBox(height: 11 * sizeUnit),
          Row(
            children: [
              AnimatedContainer(
                width: leftPadding,
                duration: duration,
                curve: curve,
              ),
              Container(
                width: bottomLineWidth,
                height: 1 * sizeUnit,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2 * sizeUnit)),
              ),
            ],
          ),
          SizedBox(height: 4 * sizeUnit),
        ],
      ),
    );
  }
}
