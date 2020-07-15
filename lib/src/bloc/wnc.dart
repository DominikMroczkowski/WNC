import 'package:kda/src/models/symbol.dart' as models;
import 'package:kda/src/models/step.dart' as models;

class WNC {
	static int max = 65536;

	static getLH(int lenght, String symbol, List<models.Symbol> symbols) {
		int l = 0;
		int h = 0;

		double pSum = 0;
		for (int i = 0; i < symbols.length; i++) {
			if (symbols[i].character == symbol) {
				l = ((pSum * lenght)/100).floor();
				h = (((pSum + symbols[i].probability) * lenght)/100).floor();
				break;
			}

			pSum = pSum + symbols[i].probability;
		}

		return [l, h];
	}

	static List<models.EncodingStep> encode(List<models.Symbol> symbols, String message) {
		List<models.EncodingStep> steps = [];

		// initialization
		steps.add(
			models.EncodingStep(
				symbol: 'INITIALZATION',
				l: 0,
				h: max,
				k: 0,
				newBits: null
			)
		);

		for (int i = 0; i < message.length + 2;) {
			var s = steps.last;

			// underflow condition
			if (max/4 <= s.l && s.l < max/2 && max/2 < s.h && s.h <= (3*max)/4) {
				steps.add(
					models.EncodingStep(
						symbol: 'UNDERFLOW',
						l: ((2*s.l)-(max/2)).round(),
						h: ((2*s.h)-(max/2)).round(),
						k: s.k + 1,
						newBits: null
					)
				);
				continue;
			}

			// shift conditions
			if (s.h <= max/2) {
				steps.add(
					models.EncodingStep(
						symbol: 'SHIFT_UP',
						l: 2*s.l,
						h: 2*s.h,
						k: 0,
						newBits: '0' + ('1' * s.k)
					)
				);
				continue;
			}

			if (max/2 <= s.l) {
				steps.add(
					models.EncodingStep(
						symbol: 'SHIFT_DOWN',
						l: (2*s.l - max),
						h: (2*s.h - max),
						k: 0,
						newBits: '1' + ('0' * s.k)
					)
				);
				continue;
			}


			// next character
      if (i < message.length) {

		  	var lh = getLH(s.h - s.l, message[i], symbols);
			  steps.add(
				  models.EncodingStep(
					  symbol: message[i],
					  l: (s.l)+(lh[0]),
					  h: (s.l)+(lh[1]),
					  k: s.k,
					  newBits: null
				  )
			  );
      } else if (i == message.length) {
        var lh = getLH(steps.last.h - steps.last.l, 'EOF', symbols);


			steps.add(
				models.EncodingStep(
					symbol: 'EOF',
					l: (steps.last.l)+(lh[0]),
					h: (steps.last.l)+(lh[1]),
					k: steps.last.k,
					newBits: null
				)
	    );
      }
			i++;
		}

  	var nb = steps.last.l < max/4 && max/2 < steps.last.h ? '0' + ('1' * (steps.last.k + 1)) : '1' + ('0' * (steps.last.k + 1));
    steps.add(
			models.EncodingStep(
				symbol: 'EOF_BITS',
				l: steps.last.l,
				h: steps.last.h,
				k: steps.last.k,
				newBits: nb
			)
    );
		return steps;
	}
}
