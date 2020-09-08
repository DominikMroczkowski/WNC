import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:kda/src/models/symbol.dart' as models;
import 'package:kda/src/models/step.dart' as models;
import 'package:kda/src/bloc/wnc.dart';

class Bloc {
	final _character   = BehaviorSubject<String>();
	final _probability = BehaviorSubject<int>();
	final _symbols     = BehaviorSubject<List<models.Symbol>>();
	final _message     = BehaviorSubject<String>();
	final _m           = BehaviorSubject<int>();
	final _steps       = BehaviorSubject<List<models.EncodingStep>>();

	get changeCharacter                 => _character.sink.add;
	Function(int) get changeProbability => _probability.sink.add;
	get changeMessage                   => _message.sink.add;
	get changeM                         => _m.sink.add;
	Stream<bool> get addSymbolValid     => Rx.combineLatest2(character, probability, (c, p) => true);

	get character   => _character.stream.transform(_validateCharacter());
	get probability => _probability.stream;
	get symbols     => _symbols.stream;
	get message     => _message.stream.transform(_validateMessage());
	get m           => _m.stream;
	get steps       => _steps.stream;

	_validateCharacter() {
		return StreamTransformer<String, dynamic>.fromHandlers(
			handleData: (item, sink) {
				if (null == item || '' == item) {
					sink.addError('Brak Wartości');
					return;
				}

				var list = _symbols.value ?? [];

				for (int i = 0; i < list.length; i++)
					if (list[i].character == item) {
						sink.addError('Wartość istnieje w liście');
						return;
					}

				sink.add(item);
			}
		);
	}


	_validateMessage() {
		return StreamTransformer<String, dynamic>.fromHandlers(
			handleData: (item, sink) {
				if ('' == item || null == item) {
					sink.addError('Brak Wartości');
					return;
				}

				var symbols = _symbols.value ?? [];

				for (int i = 0; i < item.length && symbols.length > 0; i++) {
					bool found = false;

					for (int j = 0; j < symbols.length; j++) {
						if (symbols[j].character == item[i])
							found = true;
					}

					if (found == false) {
						print('adding here');
						sink.addError('Zawiera niezidentyfikowane symbole');
						return;
					}
				}

				sink.add(item);
			}
		);
	}

	addSymbol() {
		var list = _symbols.value ?? [];

		for (int i = 0; i < list.length; i++)
			if (list[i].character == _character.value) {
				return;
			}

		list.add(
			models.Symbol(
				probability: _probability.value,
				character: _character.value
			)
		);

		_symbols.sink.add(list);
	}

	deleteSymbols() {
		_symbols.add([]);
	}

	deleteSymbol(int index) {
		var list = _symbols.value ?? [];

		if (list.length < index)
			return;

		list.removeAt(index);
		_symbols.sink.add(list);
	}

	submitMessage(BuildContext context) {
		_steps.add(
			WNC.encode(
				_symbols.value,
				_message.value,
				_m.value
			)
		);
		Navigator.of(context).pushNamed('/answer');
	}

	Bloc() {
		_character.sink.add(null);
		_message.sink.add(null);
	}

	dispose() {
		_character.close();
		_probability.close();
		_symbols.close();
		_message.close();
		_m.close();
		_steps.close();
	}
}
