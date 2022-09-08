/*
 * generated by Xtext 2.25.0
 */
package circus.robocalc.sleec.generator

import circus.robocalc.sleec.sLEEC.Atom
import circus.robocalc.sleec.sLEEC.BoolComp
import circus.robocalc.sleec.sLEEC.BoolValue
import circus.robocalc.sleec.sLEEC.Boolean
import circus.robocalc.sleec.sLEEC.Constant
import circus.robocalc.sleec.sLEEC.Defeater
import circus.robocalc.sleec.sLEEC.Definition
import circus.robocalc.sleec.sLEEC.Event
import circus.robocalc.sleec.sLEEC.MBoolExpr
import circus.robocalc.sleec.sLEEC.Measure
import circus.robocalc.sleec.sLEEC.Not
import circus.robocalc.sleec.sLEEC.Numeric
import circus.robocalc.sleec.sLEEC.RelComp
import circus.robocalc.sleec.sLEEC.Response
import circus.robocalc.sleec.sLEEC.Rule
import circus.robocalc.sleec.sLEEC.Scale
import circus.robocalc.sleec.sLEEC.TimeUnit
import circus.robocalc.sleec.sLEEC.Trigger
import circus.robocalc.sleec.sLEEC.Type
import circus.robocalc.sleec.sLEEC.Value
import java.util.Collections
import java.util.List
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.AbstractGenerator
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext
import java.util.Set
import org.eclipse.emf.ecore.util.EcoreUtil
import java.util.HashSet
import java.io.File

/**
 * Generates code from your model files on save.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#code-generation
 */
class SLEECGenerator extends AbstractGenerator {

	Set<String> scaleIDs
	Set<String> measureIDs
	
	override void doGenerate(Resource resource, IFileSystemAccess2 fsa, IGeneratorContext context) {
		this.scaleIDs = resource.allContents
			.filter(Measure)
			.filter[ it.type instanceof Scale ]
			.map[ 'v' + it.name ]
			.toSet
		this.measureIDs = resource.allContents
			.filter(Measure)
			.map[name]
			.toSet
		
		val ticktock = new File("../src-gen/ticktock.csp")
		if (!ticktock.exists()){
			generateTickTock(resource, fsa, context)
		}
		
		fsa.generateFile(
			resource.getURI().trimFileExtension().lastSegment() + '.csp', '''
			include "ticktock.csp"
			external prioritise
			
			
			«resource.allContents
				.filter(Definition)
				.toIterable
				.map[D]
				.join('')»
				
			Capabilities = 
			  {| «resource.allContents
								.filter(Definition)
								.filter(Event)
								.toIterable
								.map[Cap]
								.join(',' + '\n   ')»,
				 «resource.allContents
								.filter(Definition)
								.filter(Measure)
								.toIterable
								.map[Cap]
								.join(',' + '\n')»
			  |}
			Measures =
			  {| «resource.allContents
								.filter(Definition)
								.filter(Measure)
								.toIterable
								.map[Meas]
								.join(',' + '\n   ')»
			  |}
				
			instance MSN = MS(Capabilities)
			Timed(et) {
			
			«resource.allContents
				.filter(Rule)
				.toIterable
				.map[ rule | show(rule) + '\n' + R(rule) ]
				.join('')»
				
			-- ASSERTIONS --
			
			«resource.allContents
							.filter(Rule)
							.toList
							.generateAssertions»
			
			}
		''')
	}
	
	// -----------------------------------------------------------
	
	private def Cap(Definition d) {
		'''«d.name»'''
	}
	private def Meas(Definition d) {
		'''«d.name»'''
	}
	
	// -----------------------------------------------------------
	
	private def D(Definition d) {
		switch d {
			// [[event eID]]D
			Event : '''
				channel «d.name»
			'''
			// [[measure mID : T]]D
			Measure : '''
				channel «d.name» : «T(d.type, d.name)»
			'''
			// constant cID = v]]D
			Constant : '''
				«d.name» = «norm(d.value)»
			'''
		}
	}
	
	private def T(Type t, String mID) {
		switch t {
			Boolean : 'Bool'
			Numeric : 'Int'
			Scale : { 
				val sps = t.scaleParams.map[name]
				'''
				ST«mID»
				
				datatype ST«mID» = «sps.join(" | ")»
				
				STle«mID»(v1«mID», v2«mID») =
					if v1«mID» == «sps.head» then true
					«(1 ..< sps.size - 1).map[
						'''else (if v1«mID» == «sps.get(it)» then not member(v2«mID»,{«sps.take(it).join(', ')»})'''
					].join('\n')»
					else v2«mID» == «sps.last»«')'.repeat(sps.size-2)»
					
				STeq«mID»(v1«mID», v2«mID») =
					v1«mID» == v2«mID»
					
				STlt«mID»(v1«mID», v2«mID») =
					STle«mID»(v1«mID», v2«mID») and STne«mID»(v1«mID», v2«mID»)
					
				STgt«mID»(v1«mID», v2«mID») =
					STle«mID»(v2«mID», v1«mID»)
					
				STne«mID»(v1«mID», v2«mID») =
					not STeq«mID»(v1«mID», v2«mID»)
					
				STge«mID»(v1«mID», v2«mID») =
					STlt«mID»(v2«mID», v1«mID»)
				
				'''
			}
		}
	}
	
	// -----------------------------------------------------------

	private def R(Rule r) {
		val rID = r.name
		val trig = r.trigger
		val resp = r.response
		val dfts = r.defeaters
		
		// [[rID when trig then resp dfts]]R
		'''
		«rID» = Trigger«rID»; Monitoring«rID»; «rID»
		
		Trigger«rID» = «TG(trig, 'SKIP', 'Trigger'+rID)»
		
		Monitoring«rID» = «RDS(resp, dfts, trig, alpha(resp) + dfts.flatMap[ alpha(it) ], 'Monitoring'+rID)»
		
		-- alphabet for «rID» 
		A«rID» = {|«alphabetString(r)»|}
		SLEEC«rID» = timed_priority(«rID»)
		
		
		'''
	}

	// -----------------------------------------------------------
		
	private def generateAlphabet(Rule r){
		// creates an alphabet containing all the event IDs and measure IDs used in a rule		
		var Set<String> ruleAlphabet = new HashSet<String>()
		
		ruleAlphabet.add(r.trigger.event.name)		
		getResponseEvents(r.response, ruleAlphabet)
		ruleAlphabet.addAll(alpha(r))		
		
		return ruleAlphabet
				
	}
	
	private def Set<String> getResponseEvents(Response r, Set<String> ruleAlphabet){
		val resp = r.response	
		if (resp === null){
			ruleAlphabet.add(r.event.name)
			return ruleAlphabet
		} else {		
			getResponseEvents(resp, ruleAlphabet)
		}		
	}
	
	private def alphabetString(Rule r){
		
		val Set<String> ruleAlphabet = new HashSet<String>(generateAlphabet(r))
		var String alphString = ''
		for (i : 0 ..< ruleAlphabet.size){
			val element = ruleAlphabet.get(i)
			if (i == (ruleAlphabet.size - 1)){
				alphString += element
			}else {
				alphString += element + ', '
			}			
		}		
		'''«alphString»'''
	}
	
	// -----------------------------------------------------------	
	
	private def TG(Trigger trig, String sp, String fp) {
		val eID = trig.event.name
		val mBE = trig.expr
		
		// [[eID,sp,fp]]TG
		if(mBE === null) '''
			«eID» -> «sp»
		'''
		
		// [[eID and mBE,sp,fp]]TG
		else '''
			let
				MTrigger = «ME(alpha(mBE), mBE, sp, fp)»
			within «eID» -> MTrigger
		'''
	}
	
	private def CharSequence ME(List<String> mIDs, MBoolExpr mBE, String sp, String fp) {
		 val mID = mIDs.head
		
		// [[<>,mBE,sp,fp]]ME
		if(mID === null) '''
			if «norm(mBE)» then «sp» else «fp»
		'''
			
		// [[<mID>^mIDs,mBE[vmID/mID],sp,fp]]ME
		else'''
			StartBy(«mID»?v«mID» ->
				«ME(mIDs.subList(1, mIDs.size), replace(mBE, 'v'+mID, mID), sp, fp)»
			,0)
		'''
	}
	
	// -----------------------------------------------------------
	
	private def RDS(Response resp, Iterable<Defeater> dfts, Trigger t, Iterable<String> ARDS, String mp) {
		// [[resp,trig,ARDS,mp]]RDS
		if(dfts.isEmpty)
			RP(resp)
		
		// [[resp dfts,trig,ARDS,mp]]RDS
		else '''
			let
				«LRDS(resp, dfts, t, ARDS, mp, 1)»
			within «CDS(dfts.flatMap[alpha], dfts, dfts.size+1)»
		'''
	}
		
	// -----------------------------------------------------------
	
	private def CharSequence RP(Response r) {
		val eID = r.event.name
		val v = r.value
		val tU = r.unit
		val resp = r.response
		
		// [[not eID within v tU]]
		if(r.not) 
			'''WAIT(«norm(v, tU)»)'''
		
		// [[eID]]RP
		else if(v === null)
			'''«eID» -> SKIP'''
		
		// [[eID within v tU]]RP
		else if(resp === null)
			'''StartBy(«eID» -> SKIP,«norm(v, tU)»)'''
		
		// [[eID within v tU otherwise resp]]RP
		else
			'''TimedInterrupt(«eID» -> SKIP,«norm(v, tU)»,«RP(resp)»)'''
	}
	
	// -----------------------------------------------------------
	
	private def LRDS(Response resp, Trigger trig, Iterable<String> AR, String mp, Integer n) {
		// [[<resp>,trig,AR,mp,n]]
		// assuming RP is used instead of R as the argument is a response
		if(resp !== null) '''
			Monitoring«n» = «RP(resp)»
		'''
		
		// [[<SKIP>,trig,AR,mp,n]]
		else '''
			Monitoring«n» = «TG(trig, mp, '''Monitoring«n»''')»
			«AR.map[ '''	[] «it»?x -> Monitoring«n»''' ].join('\n')»
		'''
	}
	
	// [[<resp>^resps,trig,AR,mp,n]]LRDS
	private def CharSequence LRDS(Response resp, Iterable<Defeater> dfts, Trigger trig, Iterable<String> AR, String mp, Integer n) '''
		«LRDS(resp, trig, AR, mp, n)»
		«if(!dfts.isEmpty)
			LRDS(dfts.head.response, dfts.tail, trig, AR, mp, n+1)»
	'''

	// -----------------------------------------------------------	
	
	private def CharSequence CDS(Iterable<String> mIDs, Iterable<Defeater> dfts, Integer n) {
		// [[<>,dfts,n]]CDS
		if(mIDs.isEmpty)
			return EDS(dfts, 'Monitoring1', n)
		
		// [[<mID>^mIDs,dfts,n]]CDS
		val mID = mIDs.head
		'''
		StartBy(«mID»?v«mID» ->
			«CDS(mIDs.tail, dfts.map[ replace(it, 'v'+mID, mID) ], n)»
		,0)
		'''
	}
	
	// [[unless mBE,fp,n]]EDS
	// [[unless mBE then resp,fp,n]]EDS
	private def EDS(Defeater dft, CharSequence fp, Integer n) {
		val mBE = dft.expr
		'''
		if «norm(mBE)» then Monitoring«n»
		else («fp»)'''
	}
	
	// [[dfts dft,fp,n]]EDS
	private def CharSequence EDS(Iterable<Defeater> dfts, CharSequence fp, Integer n) {
		if(dfts.isEmpty)
			fp
		else
			EDS(dfts.head, EDS(dfts.tail, fp, n-1), n)
	}

	// -----------------------------------------------------------
		
	private def generateAssertions(List<Rule> rules){
		
		var assertions = ''
		
		for (i : 0..< rules.size - 2) {
			
			var firstRule = rules.get(i)
			var firstAlphabet = generateAlphabet(firstRule)
			
			for (j : i+1 ..< rules.size - 1) {
				
				var secondRule = rules.get(j)
				var secondAlphabet = generateAlphabet(secondRule)
				// Check intersection of rule alphabets
				var intersection = new HashSet<String>(firstAlphabet)
				intersection.retainAll(secondAlphabet)
				
				if (!intersection.isEmpty){
					assertions += '''
					«CC(firstRule, secondRule)»
					«UC(firstRule, secondRule)»
					'''
				}
			}
		}
		if (assertions === ''){
			return '''-- No intersections of rules; no assertions can be made. --'''
		}else {
			return assertions		
		}
	}
	
	private def CC(Rule firstRule, Rule secondRule){
		// [[r1,r2]]CC
		'''
		assert timed_priority(«CP(firstRule, secondRule)»):[deadlock-free]
		
		'''
	}
	
	private def CP(Rule firstRule, Rule secondRule){
		//[[r1,r2]]CP
		'''«firstRule.name»|[inter({|«alphabetString(firstRule)»|}, {|«alphabetString(secondRule)»)|}]|«secondRule.name»'''
	}

	private def UC(Rule firstRule, Rule secondRule){
		//[[r1,r2]]UC
		'''
		assert not
		  MSN::C3(timed_priority(«CP(firstRule, secondRule)» \ «alpha(firstRule) + alpha(secondRule)»)
		  [T=
		  MSN::C3(timed_priority(«firstRule.name» \ «(alpha(firstRule) + alpha(secondRule)).toString»)
		   
		   
		'''
		
	}	
	
	
	// -----------------------------------------------------------
	
	// helper functions used in the translation rules:
	
	// Returns a list of all the MeasureIds in AST
	private def <T extends EObject> List<String> alpha(T AST) {
		// eAllContents does not include the root of the tree
		// so this will return an empty list if AST is an instance of Atom, which is an error
		// so first check that AST is an instance of atom
		val Iterable<Atom> leaves = if(AST instanceof Atom)
			// create a 1 element list with the atom's measureID
			Collections.singleton(AST as Atom)
		else
			AST.eAllContents
				.filter(Atom)
				.toList
		// the name of an atom can either be a measureID or a scaleParam
		// filter out the scaleParams 
		return leaves
			.map[measureID]
			.filter[this.measureIDs.contains(it)]
			.toList
	}
	
	// return an MBoolExpr as a string using CSP operators
	private def CharSequence norm(MBoolExpr mBE) {
		'(' + switch(mBE) {
			BoolComp : norm(mBE as BoolComp)
			Not : norm(mBE as Not)
			RelComp : norm(mBE as RelComp)
			Atom : norm(mBE as Atom)
			Value : norm(mBE as Value)
			BoolValue : norm(mBE as BoolValue)
		} + ')'
	}
	
	private def norm(BoolComp b) {
		norm(b.left) + switch(b.op) {
			case AND : ' and '
			case OR : ' or '
		} + norm(b.right)
	}
	
	private def norm(Not n) {	
		// no need to check that n.expr is null
		'not ' + norm(n.expr)
	}
	
	private def norm(RelComp r) {
		// the validation pass ensures that one of the arguments is a measureID
		// so the case where both are scaleParams can be ignored
		if(isScaleID(r.left) || isScaleID(r.right))
		{
			// if the arguments are scale types then they are atoms
			val left = (r.left as Atom).measureID
			val right = (r.right as Atom).measureID
			val scaleType = (isScaleID(left) ? left : right).substring(1)
			'''ST«switch(r.op) {
				case LESS_THAN : 'lt'
				case GREATER_THAN : 'gt'
				case NOT_EQUAL : 'ne'
				case LESS_EQUAL : 'le'
				case GREATER_EQUAL : 'ge'
				case EQUAL : 'eq'
			}»«scaleType»(«left», «right»)'''
		}
		else
			norm(r.left) + switch(r.op) {
				case LESS_THAN : ' < '
				case GREATER_THAN : ' > '
				case NOT_EQUAL : ' != '
				case LESS_EQUAL : ' <= '
				case GREATER_EQUAL : ' >= '
				case EQUAL : ' == '
			} + norm(r.right)
	}
	
	private def norm(Atom a) {
		a.measureID
	}
	
	private def CharSequence norm(Value v) {
		if(v.constant === null)
			v.value.toString
		else
			norm(v.constant.value)
	}
	
	private def norm(BoolValue b) {
		b.value.toString
	}
	
	// Convert value to seconds.
	// NOTE the standard unit may need to be changed from seconds depending on the implementation.
	private def norm(Value v, TimeUnit tU)
		'''(«norm(v)» * «norm(tU)»)'''
		
	private def Integer norm(TimeUnit tU) {
		switch(tU) {
			case SECONDS : 1
			case MINUTES : 60
			case HOURS : 60 * norm(TimeUnit.MINUTES)
			case DAYS : 24 * norm(TimeUnit.HOURS)
		}
	}
	
	// replace each MeasureID in the AST with 'vmID'
	private def <T extends EObject> replace(T AST, String vmID, String mID) {
		val res = EcoreUtil.copy(AST)
		if(res instanceof Atom)
			res.measureID = vmID
		else
			res.eAllContents
				.filter(Atom)
				.filter[ it.measureID == mID ]
				.forEach[ it.measureID = vmID ]
		return res
	}
	
	// -----------------------------------------------------------
	
	// functions used for AST printing TODO this could be done during serialisation
	
	private def CharSequence show(Rule r) '''
		-- «r.name» when «show(r.trigger)» then «show(r.response)» «r.defeaters.map[show].join('')»
	'''

	private def show(Trigger t) {
		t.event.name + if (t.expr === null)
			''
		else
			' and ' + norm(t.expr)
	}

	private def CharSequence show(Response r) {
		if (r.not)
			'not ' + r.event.name + ' within ' + norm(r.value) + ' ' + show(r.unit)
		else
			r.event.name + if (r.value === null)
				''
			else 
				' within ' + norm(r.value) + ' ' + show(r.unit) + if(r.response === null)
					''
				else
					'\n-- otherwise ' + show(r.response)
	}
	
	private def show(TimeUnit t) {
		switch(t) {
			case SECONDS: 'seconds'
			case MINUTES: 'minutes'
			case HOURS: 'hours'
			case DAYS: 'days'
		}
	}
	
	private def show(Defeater d) {
		'\n-- unless ' + norm(d.expr) + if(d.response === null)
			''
		else
			' then ' + show(d.response)
	}
	
	// -----------------------------------------------------------
	
	private def isScaleID(MBoolExpr m) {
		m instanceof Atom && isScaleID((m as Atom).measureID)
	}
	
	private def isScaleID(String measureID) {
		this.scaleIDs.contains(measureID)
	}
	
	
	// -----------------------------------------------------------
	// Generates ticktock.csp in src-gen if it does not exist.
	// -----------------------------------------------------------
	private def generateTickTock(Resource resource, IFileSystemAccess2 fsa, IGeneratorContext context) {
		fsa.generateFile('ticktock.csp', '''---------------------------------------------------------------------------
	-- Below, we have the encoding of the tock-CSP semantics ------------------
	---------------------------------------------------------------------------
	
	---------------------------------------------------------------------------
	-- Pedro Ribeiro <pedro.ribeiro@york.ac.uk>
	-- Department of Computer Science
	-- University of York
	-- York, YO10 5GH
	-- UK
	---------------------------------------------------------------------------
	
	
	---------------------------------------------------------------------------
	-- SUMMARY AND ACKNOWLEDGMENTS
	---------------------------------------------------------------------------
	--
	-- This file contains an encoding of 'tick-tock'-CSP, as well as encodings
	-- for the Refusal Testing model. This work is based on a tailoring (and
	-- an extension to cater for termination) of a technique by David Mestel,
	-- originally available at:
	
	-- http://www.cs.ox.ac.uk/people/david.mestel/model-shifting.csp
	--
	-- That work referred to the strategy outlined in the following paper:
	--
	-- Mestel, D. and Roscoe, A.W., 2016. Reducing complex CSP models
	-- to traces via priority. Electronic Notes in Theoretical Computer
	-- Science, 325, pp.237-252.
	--
	-- The current file extends that work to 'tick-tock'-CSP, whose details
	-- can be found in the paper:
	--
	-- Baxter, J. and Ribeiro, P. and Cavalcanti, A. Reasoning with tock-CSP
	-- with FDR.
	--
	-- We observe that in that paper a refusal of an event e is encoded as e',
	-- whereas here a refusal e is encoded as ref.e. This is a technicality
	-- that enables the declaration of a parametric channel based solely on a
	-- set of regular events. Furthermore we take advantage of FDR's Modules
	-- to encapsulate the encoding within a MS(x) module where x is a set of
	-- events. It exports two parametric processes, C3(P) corresponding to the
	-- encoding of tick-tock, and CRT(P), corresponding to refusal-testing.
	--
	---------------------------------------------------------------------------
	
	---------------------------------------------------------------------------
	-- USAGE
	---------------------------------------------------------------------------
	--
	-- Modelling:
	--
	-- Processes in 'tick-tock' are modelled within a Timed Section, declared as
	-- Timed(et) { ... }. Untimed operators USTOP and Int(P,Q) (untimed interrupt)
	-- are defined below for convenience.
	--
	-- Instantiating the encoding:
	--
	-- Given a set of events of interest {a,b,c}, the encoding can be instantiated as:
	-- instance M = MS({a,b,c}).
	--
	-- Refinement checking:
	--
	-- To check that P is refined by Q in the tick-tock model the following
	-- assertion should be written:
	--
	-- assert M::C3(P) [T= M::C3(Q)
	--
	---------------------------------------------------------------------------
	
	---------------------------------------------------------------------------
	-- DEFINITIONS
	---------------------------------------------------------------------------
	
	---------------------------------------------------------------------------
	-- Auxiliary definitions for tick-tock-CSP modelling
	---------------------------------------------------------------------------
	
	channel tock
	
	USTOP = STOP
	et(_) = 0
	
	UInt(P,Q) = P /\ Q
	
	Timed(et) {
		TSTOP = STOP
		EndBy(P,d) = P /\ (WAIT(d) ; USTOP)
		StartBy(P,d) = P [] (WAIT(d) ; USTOP)
	    Deadline(c,d) = StartBy(c -> SKIP,d)
	
	    channel finishedp, finishedq, timeout
		TimedInterrupt(P,d,Q) =
	      ((((P; Deadline(finishedp,0))
	        /\ timeout -> (RUN(diff(Events,{finishedp,finishedq,timeout}))
	                       /\ finishedq -> SKIP)
	       )
	         [| Events |]
	       RT(d,Q)) \ {finishedp, finishedq, timeout}); SKIP
	
	}
	
	
	RT(d,Q) = if d > 0
	          then RUN(diff(Events,{finishedp, finishedq, timeout, tock})) /\ (finishedp -> SKIP [] tock -> RT(d-1,Q))
		      else timeout -> Q; finishedq -> SKIP
	
	---------------------------------------------------------------------------
	-- Semantic encoding
	---------------------------------------------------------------------------
	
	external prioritisepo
	
	module MS(Sigma)
	
	-- Note that for the purposes of encoding refusals/acceptances in this model
	-- ref.x, rather than x' is used, unlike that discussed in the paper. This
	-- is a technicality as it makes it easier to defined a parametrised channel.
	
	channel ref:union(Sigma,{tock,tick})
	channel acc:union(Sigma,{tock,tick})
	
	channel stab
	channel tick
	
	-- The partial order gives each event 'x' priority over 'ref.x'
	order = {(x,ref.x) | x:union(Sigma,{tock,tick})}
	
	---------------------------------------------------------------------------
	-- Context C1
	---------------------------------------------------------------------------
	
	-- This is the first context, whereby in interleaving with P we have the
	-- process that can perform ref or stab, and is prioritised according to
	-- 'order', whereby 'Sigma' have same priority as 'tau' and 'tick'.
	--
	-- This is effectively an implementation of the RT-model, because after each
	-- normal trace (ie, with events drawn from Sigma) we have the possibility
	-- to also observe in the trace refusal information, at that point.
	
	C1(P) = prioritisepo(P ||| RUN({|ref,stab|}), union(Sigma,{|ref,tock,tick|}), order, union(Sigma,{tock,tick}))
	
	---------------------------------------------------------------------------
	-- Encoding of 'tick-tock'-CSP model
	---------------------------------------------------------------------------
	
	C2(P) = C1(P) [| union(Sigma,{|ref,stab,tock,tick|}) |] Sem
	
	Sem = ([] x : union(Sigma,{tock,tick}) @ x -> Sem)
	      [] (ref?x -> Ref)
	      [] (stab -> Ref)
	
	Ref = (ref?x -> Ref) [] (stab -> Ref) [] tock -> Sem
	
	exports
	
	-- Refusal-testing (via refusals)
	CRT(P) = C1(P ; tick -> SKIP)
	
	-- tick-tock (via refusals)
	C3(P) = C2(P ; tick -> SKIP)
	
	endmodule
	---------------------------------------------------------------------------
	'''
			)
	}
	
}
