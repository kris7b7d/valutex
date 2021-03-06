import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'currency_draft.dart';
import '../exchange_currency.dart';
import '../keypad.dart';
import '../app_settings.dart';
import '../localization.dart';

ExchangeCurrency exchangeCurrency = ExchangeCurrency();
AppSettings appSettings = AppSettings();

class AmountScreen extends StatefulWidget {
  final CountryDetails countryDetails;
  final num initialAmount;
  final num maxAmount;
  final String lang;

  AmountScreen({
    Key key,
    @required this.countryDetails,
    @required this.initialAmount,
    @required this.maxAmount,
    @required this.lang,
  })  : assert(countryDetails != null),
        assert(initialAmount != null),
        assert(maxAmount != null),
        assert(lang != null),
        super(key: key);

  createState() => _AmountScreenState();
}

class _AmountScreenState extends State<AmountScreen> {
  final bool useAmountPrefix = true;
  final int maxLength = 12;
  TextEditingController _inputTextFieldController;
  bool _isValidationError = false;
  String _textValidationError = '';
  num amountValue;

  @override
  void initState() {
    super.initState();
    amountValue = appSettings.inputAmountRound
        ? widget.initialAmount.round()
        : widget.initialAmount;
    amountValue = (amountValue != 0) ? amountValue : 1;
    _inputTextFieldController =
        TextEditingController(text: amountValue.toString());
  }

  _storeAmount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('amountInput', amountValue.toString());
    prefs.setString('currencyInput', widget.countryDetails.currencyCode);
  }

  void _updateAmoutValue(String input) {
    if (input.length > 1) {
      if ((input[0].compareTo('0') == 0) && (input[1].compareTo('.') != 0)) {
        input = input.substring(1, input.length);
      }
    }

    setState(() {
      if (input == null || input.isEmpty) {
        amountValue = 1;
      } else {
        // Even though we are using the numerical keyboard, we still have to check
        // for non-numerical input such as '5..0' or '6 -3'
        try {
          amountValue = double.parse(input);
          _isValidationError = false;
        } on Exception catch (e) {
          debugPrint('Error: $e');
          _isValidationError = true;
          _textValidationError =
              AppLocalizations.of(context).inputErrorInvalidAmount;
        }
        if (!_isValidationError && (amountValue > widget.maxAmount)) {
          _isValidationError = true;
          _textValidationError =
              AppLocalizations.of(context).inputErrorAmountToHigh;
        }
        if (!_isValidationError && (amountValue == 0)) {
          _isValidationError = true;
          _textValidationError =
              AppLocalizations.of(context).inputErrorNonZeroAmount;
        }
      }
      String text = input;
      _inputTextFieldController.value = TextEditingValue(text: text);
    });
  }

  String amountPrefix() {
    if (!useAmountPrefix) return '';
    if (_inputTextFieldController.text.length == 0) return '';
    return widget.countryDetails.currencySymbol + ' ';
  }

  String formattedAmount(num amountValue) {
    return amountValue.toString();
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      title: Text(AppLocalizations.of(context).screenTitleSetAmount),
    );

    final upperBox = Padding(
      padding: EdgeInsets.all(0.0),
      child: CurrencyDraft(
        label: 'amount-flag-' + widget.countryDetails.flagCode,
        flagCode: widget.countryDetails.flagCode,
        detail1: widget.countryDetails.countryNameTr,
        detail2: widget.countryDetails.currencyNameTr,
        tailWidget: Text(
          (useAmountPrefix)
              ? '${widget.countryDetails.currencyCode}'
              : '${widget.countryDetails.currencySymbol}    ${widget.countryDetails.currencyCode}',
          style: TextStyle(fontSize: 18.0),
          textAlign: TextAlign.right,
        ),
      ),
    );

    final inputBox = Padding(
      padding: EdgeInsets.all(16.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Stack(
              //alignment: const Alignment(1.0, 0.0),
              children: <Widget>[
                TextField(
                  controller: _inputTextFieldController,
                  decoration: InputDecoration(
                    hintText:
                        AppLocalizations.of(context).inputPlaceHolderAmount,
                    errorText: _isValidationError ? _textValidationError : null,
                  ),
                  style: TextStyle(
                    fontSize: 32.0 * appSettings.scaleWidth,
                    color: Colors.transparent,
                  ),
                  onChanged: _updateAmoutValue,
                ),
                Container(
                  color: Colors.transparent,
                  //padding: EdgeInsets.all(40.0),
                  height: 160.0,
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(top: 0.0, right: 12.0),
                        child: Text(
                          //'${amountPrefix()}${_inputTextFieldController.text}',
                          '${amountPrefix()}${exchangeCurrency.applyNotation(_inputTextFieldController.text, appSettings.europeanNotation)}',
                          style: TextStyle(
                            fontSize: 32.0 * appSettings.scaleWidth,
                          ),
                          textAlign: TextAlign.end,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    InkWell(
                      child: IconButton(
                        icon: Icon(Icons.backspace),
                        padding: EdgeInsets.all(12.0),
                        iconSize: 32.0 * appSettings.scaleWidth,
                        onPressed: () {
                          {
                            String text = _inputTextFieldController.text;
                            if (text.length > 0) {
                              text = text.substring(0, text.length - 1);
                              _inputTextFieldController.value =
                                  TextEditingValue(text: text);
                              _updateAmoutValue(text);
                            }
                          }
                        },
                      ),
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      onLongPress: () {
                        _inputTextFieldController.clear();
                        _updateAmoutValue('');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    final body = Stack(
      children: <Widget>[
        Container(
          child: Column(
            children: <Widget>[
              upperBox,
              inputBox,
            ],
          ),
        ),
        Keypad(
          activeTextFieldController: _inputTextFieldController,
          maxLength: 10,
          onSubmit: () {
            _updateAmoutValue(_inputTextFieldController.text);
            if (!_isValidationError) {
              _storeAmount();
              Navigator.pop(context, amountValue);
            }
          },
          onChange: () {
            _updateAmoutValue(_inputTextFieldController.text);
          },
        ),
      ],
    );

    return Scaffold(
      appBar: appBar,
      body: body,
    );
  }
}
