/*
 * generated by Xtext 2.25.0
 */
package circus.robocalc.sleec.parser.antlr;

import circus.robocalc.sleec.parser.antlr.internal.InternalSLEECParser;
import circus.robocalc.sleec.services.SLEECGrammarAccess;
import com.google.inject.Inject;
import org.eclipse.xtext.parser.antlr.AbstractAntlrParser;
import org.eclipse.xtext.parser.antlr.XtextTokenStream;

public class SLEECParser extends AbstractAntlrParser {

	@Inject
	private SLEECGrammarAccess grammarAccess;

	@Override
	protected void setInitialHiddenTokens(XtextTokenStream tokenStream) {
		tokenStream.setInitialHiddenTokens("RULE_WS", "RULE_ML_COMMENT", "RULE_SL_COMMENT");
	}
	

	@Override
	protected InternalSLEECParser createParser(XtextTokenStream stream) {
		return new InternalSLEECParser(stream, getGrammarAccess());
	}

	@Override 
	protected String getDefaultRuleName() {
		return "Specification";
	}

	public SLEECGrammarAccess getGrammarAccess() {
		return this.grammarAccess;
	}

	public void setGrammarAccess(SLEECGrammarAccess grammarAccess) {
		this.grammarAccess = grammarAccess;
	}
}
