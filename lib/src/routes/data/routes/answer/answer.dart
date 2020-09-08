import 'package:flutter/material.dart';
import 'package:kda/src/bloc/provider.dart';
import 'package:kda/src/models/step.dart' as models;

class Answer extends StatelessWidget {
	final style = TextStyle(
		fontSize: 18
	);
	Widget build(BuildContext context) {
		return Scaffold(
			body: SafeArea(
				child: _body(context)
			),
			appBar: AppBar(
				title: Text('Odpowiedź')
			),
		);
	}

	Widget _body(BuildContext context) {
		final bloc = Provider.of(context);

		return StreamBuilder(
			stream: bloc.steps,
			builder: (context, snapshot) {
				if (snapshot.hasData)
					return SingleChildScrollView(
						child: Column(
							children: <Widget>[
								_answer(snapshot.data),
								_steps(snapshot.data)
							],
						),
						padding: EdgeInsets.all(10.0)
					);
				return CircularProgressIndicator();
			}
		);
	}

	Widget _answer(steps) {
		return Row(
			children: <Widget>[
				Expanded(child: Container()),
				Text('Wynik :', style: style),
				Container(padding: EdgeInsets.only(left: 5.0)),
				Text(_getBits(steps), style: style),
				Expanded(child: Container()),
			],
		);
	}

	String _getBits(List<models.EncodingStep> steps) {
		String s = '';
		steps.forEach((i) { if (i.newBits != null) s = s + i.newBits;});
		return s;
	}

	Widget _steps(List<models.EncodingStep> steps) {
		return Container(
			child: Column(
				children: _stepsList(steps),
			),
			padding: EdgeInsets.only(top: 10.0, bottom: 10.0)
		);
	}

	List<Widget> _stepsList(List<models.EncodingStep> steps) {
		List<Widget> list = [];
		steps.forEach((i) {list.add(_stepTile(i, steps.first.h ?? 0));});
		return list;
	}

	Widget _stepTile(models.EncodingStep step, int max) {
		return Card( child: Container(
			child: Column(
				children: <Widget>[
					Text(step != null ? step.symbol : 'inicializacja', style: style),
					Row(
						children: <Widget>[
							Text('Granica lewa (l): ' + step.l.toString()),
							Spacer(),
							Text('Granica prawa (h): ' + step.h.toString()),
						]
					),
					Container(
						child: Row(
							children: <Widget>[
								Expanded(
									child: Container(),
									flex: step.l
								),
								Expanded(
									child: Container(
										color: Colors.blue
									),
									flex: step.h - step.l
								),
								Expanded(
									child: Container(),
									flex: max - (step.h)
								),
							],
						),
						height: 10.0,
						decoration: BoxDecoration(color: Colors.grey),
					),
					Row(
						children: <Widget>[
							Text('Nowe bity: : ' + (step.newBits != null ? step.newBits : 'Brak')),
							Spacer(),
							Text('Overflow Counter(k): ' + step.k.toString()),
						]
					),
				],
			),
			padding: EdgeInsets.all(10.0)
		));
	}
}
