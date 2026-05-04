import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

const String _kRiveUrl =
    'https://public.rive.app/community/runtime-files/18317-34363-kochalo-login.riv';

class KochaloLoginAnimationWidget extends StatefulWidget {
  final double height;
  const KochaloLoginAnimationWidget({super.key, this.height = 200});

  @override
  State<KochaloLoginAnimationWidget> createState() => KochaloLoginAnimationWidgetState();
}

class KochaloLoginAnimationWidgetState extends State<KochaloLoginAnimationWidget> {
  bool _loaded = false;
  StateMachineController? _ctrl;

  SMIBool? _isCheking;
  SMIBool? _isHandUp;
  SMITrigger? _trigSuccess;
  SMITrigger? _trigFail;
  SMINumber? _numLook;

  void _onInit(Artboard artboard) {
    var ctrl = StateMachineController.fromArtboard(artboard, 'Login Machine');
    ctrl ??= StateMachineController.fromArtboard(artboard, 'State Machine 1');

    if (ctrl == null) {
      debugPrint('Kochalo ✗ Could not find any State Machine');
      return;
    }

    artboard.addController(ctrl);
    _ctrl = ctrl;
    _wireInputs(ctrl);

    if (mounted) setState(() => _loaded = true);
  }

  void _wireInputs(StateMachineController ctrl) {
    _isCheking = ctrl.findInput<bool>('isCheking') as SMIBool?;
    _isHandUp = ctrl.findInput<bool>('isHandUp') as SMIBool?;
    _trigSuccess = ctrl.findInput<bool>('trigSuccess') as SMITrigger?;
    _trigFail = ctrl.findInput<bool>('trigFail') as SMITrigger?;
    _numLook = ctrl.findInput<double>('look') as SMINumber?;

    debugPrint('Kochalo Inputs Wired: '
        'check: ${_isCheking != null}, '
        'hands: ${_isHandUp != null}, '
        'look: ${_numLook != null}');
  }

  @override
  void dispose() {
    _ctrl?.dispose();
    super.dispose();
  }


  void onEmailFocus() {
    _isHandUp?.value = false;
    _isCheking?.value = true;
  }

  void onEmailTyping(String text) {
    _isCheking?.value = true;
    _isHandUp?.value = false;
    _numLook?.value = text.length.toDouble() * 2.0;
  }

  void onPasswordFocus() {
    _isCheking?.value = false;
    _isHandUp?.value = true;
  }

  void onIdle() {
    _isCheking?.value = false;
    _isHandUp?.value = false;
  }

  void onSuccess() {
    _trigSuccess?.fire();
  }

  void onFailure() {
    _trigFail?.fire();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (!_loaded) const CircularProgressIndicator(strokeWidth: 2),
            RiveAnimation.network(
              _kRiveUrl,
              fit: BoxFit.contain,
              onInit: _onInit,
            ),
          ],
        ),
      ),
    );
  }
}
