import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SeamlessGlowButton extends StatefulWidget {
  final Widget child;
  final Function onPressed;

  SeamlessGlowButton({required this.child, required this.onPressed});
  @override
  _SeamlessGlowButtonState createState() => _SeamlessGlowButtonState();
}

class _SeamlessGlowButtonState extends State<SeamlessGlowButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 5), // Speed of the glow
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return IntrinsicWidth(
          child: IntrinsicHeight(
            child: Container(
              margin: const EdgeInsets.all(00),
              padding: const EdgeInsets.all(00),
              // width: 150,
              // height: 60,
              decoration: BoxDecoration(
                color: Colors.blue[900],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          begin: Alignment(-4.5 + 4 * _controller.value, 0.0),
                          end: Alignment(-0.0 + 4 * _controller.value, 0.0),
                          colors: [
                            CupertinoTheme.of(context).primaryColor,
                            CupertinoTheme.of(context).primaryColor.withOpacity(0.7),
                            CupertinoTheme.of(context).primaryColor,
                          ],
                          stops: [0.3, 0.5, 0.7],
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.srcATop,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: CupertinoButton(color: Colors.transparent, padding: const EdgeInsets.symmetric(horizontal: 20), onPressed: () => widget.onPressed(), child: widget.child),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
