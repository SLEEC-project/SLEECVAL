/**
 * generated by Xtext 2.25.0
 */
package circus.robocalc.sleec.sLEEC.impl;

import circus.robocalc.sleec.sLEEC.MBoolExpr;
import circus.robocalc.sleec.sLEEC.Measure;
import circus.robocalc.sleec.sLEEC.SLEECPackage;

import org.eclipse.emf.common.notify.Notification;
import org.eclipse.emf.common.notify.NotificationChain;

import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.InternalEObject;

import org.eclipse.emf.ecore.impl.ENotificationImpl;
import org.eclipse.emf.ecore.impl.MinimalEObjectImpl;

/**
 * <!-- begin-user-doc -->
 * An implementation of the model object '<em><b>MBool Expr</b></em>'.
 * <!-- end-user-doc -->
 * <p>
 * The following features are implemented:
 * </p>
 * <ul>
 *   <li>{@link circus.robocalc.sleec.sLEEC.impl.MBoolExprImpl#getMeasure <em>Measure</em>}</li>
 *   <li>{@link circus.robocalc.sleec.sLEEC.impl.MBoolExprImpl#getLeft <em>Left</em>}</li>
 * </ul>
 *
 * @generated
 */
public class MBoolExprImpl extends MinimalEObjectImpl.Container implements MBoolExpr
{
  /**
   * The cached value of the '{@link #getMeasure() <em>Measure</em>}' reference.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @see #getMeasure()
   * @generated
   * @ordered
   */
  protected Measure measure;

  /**
   * The cached value of the '{@link #getLeft() <em>Left</em>}' containment reference.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @see #getLeft()
   * @generated
   * @ordered
   */
  protected MBoolExpr left;

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  protected MBoolExprImpl()
  {
    super();
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  protected EClass eStaticClass()
  {
    return SLEECPackage.Literals.MBOOL_EXPR;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public Measure getMeasure()
  {
    if (measure != null && measure.eIsProxy())
    {
      InternalEObject oldMeasure = (InternalEObject)measure;
      measure = (Measure)eResolveProxy(oldMeasure);
      if (measure != oldMeasure)
      {
        if (eNotificationRequired())
          eNotify(new ENotificationImpl(this, Notification.RESOLVE, SLEECPackage.MBOOL_EXPR__MEASURE, oldMeasure, measure));
      }
    }
    return measure;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public Measure basicGetMeasure()
  {
    return measure;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public void setMeasure(Measure newMeasure)
  {
    Measure oldMeasure = measure;
    measure = newMeasure;
    if (eNotificationRequired())
      eNotify(new ENotificationImpl(this, Notification.SET, SLEECPackage.MBOOL_EXPR__MEASURE, oldMeasure, measure));
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public MBoolExpr getLeft()
  {
    return left;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public NotificationChain basicSetLeft(MBoolExpr newLeft, NotificationChain msgs)
  {
    MBoolExpr oldLeft = left;
    left = newLeft;
    if (eNotificationRequired())
    {
      ENotificationImpl notification = new ENotificationImpl(this, Notification.SET, SLEECPackage.MBOOL_EXPR__LEFT, oldLeft, newLeft);
      if (msgs == null) msgs = notification; else msgs.add(notification);
    }
    return msgs;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public void setLeft(MBoolExpr newLeft)
  {
    if (newLeft != left)
    {
      NotificationChain msgs = null;
      if (left != null)
        msgs = ((InternalEObject)left).eInverseRemove(this, EOPPOSITE_FEATURE_BASE - SLEECPackage.MBOOL_EXPR__LEFT, null, msgs);
      if (newLeft != null)
        msgs = ((InternalEObject)newLeft).eInverseAdd(this, EOPPOSITE_FEATURE_BASE - SLEECPackage.MBOOL_EXPR__LEFT, null, msgs);
      msgs = basicSetLeft(newLeft, msgs);
      if (msgs != null) msgs.dispatch();
    }
    else if (eNotificationRequired())
      eNotify(new ENotificationImpl(this, Notification.SET, SLEECPackage.MBOOL_EXPR__LEFT, newLeft, newLeft));
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public NotificationChain eInverseRemove(InternalEObject otherEnd, int featureID, NotificationChain msgs)
  {
    switch (featureID)
    {
      case SLEECPackage.MBOOL_EXPR__LEFT:
        return basicSetLeft(null, msgs);
    }
    return super.eInverseRemove(otherEnd, featureID, msgs);
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public Object eGet(int featureID, boolean resolve, boolean coreType)
  {
    switch (featureID)
    {
      case SLEECPackage.MBOOL_EXPR__MEASURE:
        if (resolve) return getMeasure();
        return basicGetMeasure();
      case SLEECPackage.MBOOL_EXPR__LEFT:
        return getLeft();
    }
    return super.eGet(featureID, resolve, coreType);
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public void eSet(int featureID, Object newValue)
  {
    switch (featureID)
    {
      case SLEECPackage.MBOOL_EXPR__MEASURE:
        setMeasure((Measure)newValue);
        return;
      case SLEECPackage.MBOOL_EXPR__LEFT:
        setLeft((MBoolExpr)newValue);
        return;
    }
    super.eSet(featureID, newValue);
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public void eUnset(int featureID)
  {
    switch (featureID)
    {
      case SLEECPackage.MBOOL_EXPR__MEASURE:
        setMeasure((Measure)null);
        return;
      case SLEECPackage.MBOOL_EXPR__LEFT:
        setLeft((MBoolExpr)null);
        return;
    }
    super.eUnset(featureID);
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public boolean eIsSet(int featureID)
  {
    switch (featureID)
    {
      case SLEECPackage.MBOOL_EXPR__MEASURE:
        return measure != null;
      case SLEECPackage.MBOOL_EXPR__LEFT:
        return left != null;
    }
    return super.eIsSet(featureID);
  }

} //MBoolExprImpl
