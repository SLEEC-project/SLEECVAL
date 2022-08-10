/*
 * generated by Xtext 2.25.0
 */
package circus.robocalc.sleec.validation

import circus.robocalc.sleec.sLEEC.Atom
import circus.robocalc.sleec.sLEEC.BoolComp
import circus.robocalc.sleec.sLEEC.Boolean
import circus.robocalc.sleec.sLEEC.Constant
import circus.robocalc.sleec.sLEEC.Definition
import circus.robocalc.sleec.sLEEC.Event
import circus.robocalc.sleec.sLEEC.MBoolExpr
import circus.robocalc.sleec.sLEEC.Measure
import circus.robocalc.sleec.sLEEC.Not
import circus.robocalc.sleec.sLEEC.Numeric
import circus.robocalc.sleec.sLEEC.RelComp
import circus.robocalc.sleec.sLEEC.SLEECPackage
import circus.robocalc.sleec.sLEEC.Scale
import circus.robocalc.sleec.sLEEC.Specification
import circus.robocalc.sleec.sLEEC.Value
import java.util.Set
import org.eclipse.xtext.validation.Check

/** 
 * This class contains custom validation rules. 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#validation
 */
class SLEECValidator extends AbstractSLEECValidator {
	@Check
	def chechEventName(Event e) {
		if(!Character.isUpperCase(e.name.charAt(0)))
			warning("Event identifier should begin with capital letter", SLEECPackage.Literals.DEFINITION__NAME, "invalidName")
	}
	
	@Check
	def checkMeasureName(Measure m) {
		if(!Character.isLowerCase(m.name.charAt(0)))
			warning("Measure identifier should begin with lower case letter", SLEECPackage.Literals.DEFINITION__NAME, "invalidName")
	}
	
	@Check
	def checkContantName(Constant c) {
		for(var i = 0; i < c.name.length; i++) {
			if(Character.isLowerCase(c.name.charAt(i))) {
				warning("Constant identifier should be in all capitals.", SLEECPackage.Literals.DEFINITION__NAME, "invalidName")
			}
		}
	}

	@Check
	def checkExprTypes(Specification s) {
		val defBlock = s.defBlock
		val ruleBlock = s.ruleBlock
		val definitions = defBlock.eAllContents.filter(Definition).toList
		val scaleParams = defBlock.eAllContents.filter(Scale).toList.map[scaleParams].flatten.toSet
		val scaleIDs = definitions.filter[isScale].map[name].toSet
		scaleIDs.addAll(scaleParams)
		val booleanIDs = definitions.filter[isBoolean].map[name].toSet
		val numericIDs = definitions.filter[isNumeric].map[name].toSet
		val IDs = numericIDs + scaleIDs + booleanIDs

		// check for undefined variables
		ruleBlock.eAllContents.filter(Atom).toIterable.forEach [ atom |
			if (!IDs.contains(atom.measureID))
				error("Unknown variable", atom, SLEECPackage.Literals.ATOM__MEASURE_ID)
		]

		// check the types of a relational operator
		// either both arguments are either both numeric or both scale types
		ruleBlock.eAllContents.filter(RelComp).forEach [ relComp |
			if (isNumeric(relComp.left, numericIDs) != isNumeric(relComp.right, numericIDs))
				error("Both operands must be numeric type", relComp, SLEECPackage.Literals.REL_COMP__OP)
			else if (isScale(relComp.left, scaleIDs) != isScale(relComp.right, scaleIDs))
				error("Both operands must be scale type", relComp, SLEECPackage.Literals.REL_COMP__OP)
		]

		// check types of comparison and not operators
		// operands can either be a boolean value or a boolean expression
		ruleBlock.eAllContents.filter(BoolComp).forEach [ boolComp |
			if (!isBoolean(boolComp.left, booleanIDs) || !isBoolean(boolComp.right, booleanIDs))
				error("Both operands must be boolean type", boolComp, SLEECPackage.Literals.BOOL_COMP__OP)

		]
		ruleBlock.eAllContents.filter(Not).forEach [ not |
			if (!isBoolean(not.expr, booleanIDs))
				error("Operand must be boolean type", not, SLEECPackage.Literals.NOT__OP)
		]
	}

	def private isNumeric(Definition definition) {
		switch (definition) {
			Constant: true
			Measure: (definition as Measure).type instanceof Numeric
			default: false
		}
	}

	def private isScale(Definition definition) {
		switch (definition) {
			Measure: (definition as Measure).type instanceof Scale
			default: false
		}
	}

	def private isBoolean(Definition definition) {
		switch (definition) {
			Measure: (definition as Measure).type instanceof Boolean
			default: false
		}
	}

	def private isNumeric(MBoolExpr expr, Set<String> IDs) {
		switch (expr) {
			Value: true
			Atom: IDs.contains((expr as Atom).measureID)
			default: false
		}
	}

	def private isScale(MBoolExpr expr, Set<String> IDs) {
		switch (expr) {
			Atom: IDs.contains((expr as Atom).measureID)
			default: false
		}
	}

	def private isBoolean(MBoolExpr expr, Set<String> IDs) {
		switch (expr) {
			Boolean,
			Not,
			BoolComp,
			RelComp: true
			Atom: IDs.contains((expr as Atom).measureID)
			default: false
		}
	}
}
