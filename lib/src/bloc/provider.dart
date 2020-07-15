import 'package:flutter/material.dart';
import 'bloc.dart';

class Provider extends InheritedWidget {
	final session;

	Provider({Key key, Widget child}) :
		session = Bloc(),
		super(key: key, child: child);

	bool updateShouldNotify(_) => true;

	static Bloc of(BuildContext context) {
		return (context.inheritFromWidgetOfExactType(Provider) as Provider).session;
	}
}
