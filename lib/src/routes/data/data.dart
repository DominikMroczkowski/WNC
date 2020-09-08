import 'package:flutter/material.dart';
import 'package:kda/src/bloc/provider.dart';
import 'package:kda/src/models/symbol.dart' as models;
import 'package:kda/src/routes/data/routes/answer/answer.dart' as routes;

class Data extends StatelessWidget {
	final style = TextStyle(
		fontSize: 18
	);
	Widget build(BuildContext context) {
		return Navigator(
			initialRoute: '/',
			onGenerateRoute: (RouteSettings settings) {
				if (settings.name == '/answer')
					return MaterialPageRoute(
						builder: (_) => routes.Answer()
					);
				else
					return MaterialPageRoute(
						builder: (context) => Scaffold(
						body: SafeArea(
							child: _body(context)
						),
						appBar: AppBar(
							title: Text('KDA WNC')
						)
					)
				);
			}
		);
	}

	_body(BuildContext context) {
		return SingleChildScrollView(
			child: Column(
				children: <Widget>[
					_changeM(context),
					_addSymbol(context),
					_deleteSymbols(context),
					_listSymbols(context),
					_messageSegment(context)
				],
			),
			padding: EdgeInsets.all(10.0),
		);
	}

	Widget _changeM(BuildContext context) {
		return Column(
			children: <Widget>[
				_header('Określ przedział (2 ** x)'),
				_mInput(context),
				Container(height: 10.0),
			],
		);
	}

	Widget _addSymbol(BuildContext context) {
		return Column(
			children: <Widget>[
				_header('Określ symbole'),
				_addSymbolInput(context),
				Container(height: 10.0),
				_addSymbolButton(context),
				Container(height: 10.0),
			],
		);
	}

	Widget _addSymbolInput(BuildContext context) {
		return Row(
			children: <Widget>[
				Expanded(
					child: _charInput(context),
					flex: 1
				),
				Container(width: 10.0),
				Expanded(
					child: _probInput(context),
					flex: 3
				),
			],
		);
	}

	_messageSegment(BuildContext context) {
		return Column(
			children: <Widget>[
				_header('Wprowadź tekst'),
				_message(context),
				_submitMessage(context),
			],
		);
	}

	_charInput(BuildContext context) {
		final bloc = Provider.of(context);
		return StreamBuilder(
			stream: bloc.character,
			builder: (context, snapshot) {
				return TextFormField(
					onChanged: bloc.changeCharacter,
					decoration: InputDecoration(
						errorText: snapshot.error
					),
				);
			},
		);
	}

	_probInput(BuildContext context) {
		final bloc = Provider.of(context);
		return StreamBuilder(
			stream: bloc.probability,
			builder: (context, AsyncSnapshot<int> snapshot) {
				final value = snapshot.data == null ? 0.0 : snapshot.data / 100;
				return Slider(
					onChanged: (i) {bloc.changeProbability((i*100).toInt());},
					value: value ?? 0.0,
					min: 0,
					max: 1.0,
					divisions: 10,
					label: value.toString()
				);
			},
		);
	}

	_mInput(BuildContext context) {
	final bloc = Provider.of(context);
		return StreamBuilder(
			stream: bloc.m,
			builder: (context, AsyncSnapshot<int> snapshot) {
				return Slider(
					onChanged: (i) {bloc.changeM(i.toInt());},
					value: snapshot.data?.toDouble() ?? 2.0,
					min: 2.0,
					max: 16.0,
					divisions: 14,
					label: snapshot.data.toString()
				);
			},
		);

	}

	Widget _addSymbolButton(BuildContext context) {
		final bloc = Provider.of(context);
		return StreamBuilder(
			stream: bloc.addSymbolValid,
			builder: (context, snapshot) {
				return Row(
					children: <Widget>[
						Expanded(child: Container()),
					  FlatButton(
							onPressed: snapshot.data != null ? bloc.addSymbol : null,
							child: Text('Dodaj'),
					 )
				 ],
				);
			}
		);
	}

	Widget _deleteSymbols(BuildContext context) {
		final bloc = Provider.of(context);
		return StreamBuilder(
			stream: bloc.symbols,
			builder: (context, AsyncSnapshot<List<models.Symbol>> snapshot) {
				if (snapshot.hasData && snapshot.data.isNotEmpty)
					return FlatButton(
						child: Text('Wyczyść'),
						onPressed: bloc.deleteSymbols);
				else
					return Container(height: 0.0, width: 0.0);
			}
		);
	}

	Widget _listSymbols(BuildContext context) {
		final bloc = Provider.of(context);
		return StreamBuilder(
			stream: bloc.symbols,
			builder: (context, AsyncSnapshot<List<models.Symbol>> snapshot) {
				if (snapshot.hasData)
					return _symbols(snapshot.data);
				else
					return _noSymbols();
			}
		);
	}

	Widget _symbols(List<models.Symbol> list) {
		return Container(
			child: Column(
				children: list.map((i) => _symbolTile(i)).toList(),
			),
			padding: EdgeInsets.only(top: 10.0, bottom: 10.0)
		);
	}

	Widget _symbolTile(models.Symbol symbol) {
		return Card(
			child: Container(
				child: Row(
					children: [
						Text('Symbol: ' + symbol.character ?? 'null', style: style),
						Container(width: 20.0),
						Text('Prawdopodobieństwo: ' + (symbol.probability / 100).toString() ?? 'null', style: style),
					],
				),
				padding: EdgeInsets.all(10.0)
			)
		);
	}

	_message(BuildContext context) {
		final bloc = Provider.of(context);
		return StreamBuilder(
			stream: bloc.message,
			builder: (context, snapshot) {
				return TextFormField(
					onChanged: bloc.changeMessage,
					decoration: InputDecoration(
						errorText: snapshot.error
					),
				);
			},
		);
	}

	Widget _submitMessage(BuildContext context) {
		final bloc = Provider.of(context);
		return StreamBuilder(
			stream: bloc.message,
			builder: (context, snapshot) {

				return Row(
					children: <Widget>[
						Expanded(child: Container()),
						FlatButton(
							onPressed: snapshot.hasError? null : () {bloc.submitMessage(context);},
							child: Text('Oblicz'),
						)
					],
				);
			}
		);
	}

	Widget _noSymbols() {
		return Text('Brak symboli', style: style);
	}

	Widget _header(String text) {
		return Align(
			child: Text(text, style: style),
			alignment: Alignment.centerLeft
		);
	}
}
