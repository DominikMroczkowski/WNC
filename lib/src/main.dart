import 'package:flutter/material.dart';
import 'package:kda/src/routes/data/data.dart' as route;
import 'package:kda/src/bloc/provider.dart';

class App extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
		return Provider(
			child: MaterialApp(
				title: 'KDA',
				routes: {
					'/' : (_) {return route.Data();},
				},
			)
		);
  }
}
