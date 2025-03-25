import 'package:flutter/material.dart';
class LikeAnimation extends StatefulWidget {
  final Widget child;
  final bool isAnimating;
  final Duration duration;
  final VoidCallback? onEnd;
  final bool smallLike;
   LikeAnimation({
    super.key,
  required this.child,
     this.duration = const Duration(milliseconds: 150),
    required this.isAnimating,
     this.onEnd ,
     this.smallLike = false,
  });

  @override
  State<LikeAnimation> createState() => _LikeAnimationState();
}

class _LikeAnimationState extends State<LikeAnimation> with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> scale;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    animationController = AnimationController(
        vsync: this,
      duration: Duration(
        milliseconds: widget.duration.inMilliseconds ~/2,
      ),
    );
    scale = Tween<double>(begin: 1, end:  1.2).animate(animationController);
  }

  @override
  void didUpdateWidget(covariant LikeAnimation oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if(widget.isAnimating != oldWidget.isAnimating){
      startAnimation();
    }
  }


  void startAnimation()async{
    if(widget.isAnimating || widget.smallLike){
      await animationController.forward();
      await animationController.reverse();
      await Future.delayed(Duration(milliseconds: 200),);

      if(widget.onEnd != null){
          widget.onEnd!();
      }
    }
  }

 @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    animationController.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: scale,
      child: widget.child,
    );
  }
}
