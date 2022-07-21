/**
 * generated by Xtext 2.25.0
 */
package circus.robocalc.sleec.sLEEC;


/**
 * <!-- begin-user-doc -->
 * A representation of the model object '<em><b>Measure</b></em>'.
 * <!-- end-user-doc -->
 *
 * <p>
 * The following features are supported:
 * </p>
 * <ul>
 *   <li>{@link circus.robocalc.sleec.sLEEC.Measure#getType <em>Type</em>}</li>
 * </ul>
 *
 * @see circus.robocalc.sleec.sLEEC.SLEECPackage#getMeasure()
 * @model
 * @generated
 */
public interface Measure extends Definition
{
  /**
   * Returns the value of the '<em><b>Type</b></em>' containment reference.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @return the value of the '<em>Type</em>' containment reference.
   * @see #setType(Type)
   * @see circus.robocalc.sleec.sLEEC.SLEECPackage#getMeasure_Type()
   * @model containment="true"
   * @generated
   */
  Type getType();

  /**
   * Sets the value of the '{@link circus.robocalc.sleec.sLEEC.Measure#getType <em>Type</em>}' containment reference.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @param value the new value of the '<em>Type</em>' containment reference.
   * @see #getType()
   * @generated
   */
  void setType(Type value);

} // Measure
