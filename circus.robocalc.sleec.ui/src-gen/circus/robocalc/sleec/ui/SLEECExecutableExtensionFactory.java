/*
 * generated by Xtext 2.25.0
 */
package circus.robocalc.sleec.ui;

import circus.robocalc.sleec.ui.internal.SleecActivator;
import com.google.inject.Injector;
import org.eclipse.xtext.ui.guice.AbstractGuiceAwareExecutableExtensionFactory;
import org.osgi.framework.Bundle;
import org.osgi.framework.FrameworkUtil;

/**
 * This class was generated. Customizations should only happen in a newly
 * introduced subclass. 
 */
public class SLEECExecutableExtensionFactory extends AbstractGuiceAwareExecutableExtensionFactory {

	@Override
	protected Bundle getBundle() {
		return FrameworkUtil.getBundle(SleecActivator.class);
	}
	
	@Override
	protected Injector getInjector() {
		SleecActivator activator = SleecActivator.getInstance();
		return activator != null ? activator.getInjector(SleecActivator.CIRCUS_ROBOCALC_SLEEC_SLEEC) : null;
	}

}
