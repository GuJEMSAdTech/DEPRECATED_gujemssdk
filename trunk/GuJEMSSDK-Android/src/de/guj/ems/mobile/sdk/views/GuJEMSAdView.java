package de.guj.ems.mobile.sdk.views;

import java.io.IOException;
import java.util.Iterator;
import java.util.Map;

import org.ormma.view.OrmmaView;
import org.xmlpull.v1.XmlPullParser;
import org.xmlpull.v1.XmlPullParserException;

import android.content.Context;
import android.content.res.Resources;
import android.content.res.XmlResourceParser;
import android.graphics.Color;
import android.os.Handler;
import android.util.AttributeSet;
import android.util.Xml;
import android.view.View;
import android.view.ViewGroup;
import de.guj.ems.mobile.sdk.controllers.AdServerAccess;
import de.guj.ems.mobile.sdk.controllers.AmobeeSettingsAdapter;
import de.guj.ems.mobile.sdk.controllers.EMSInterface;
import de.guj.ems.mobile.sdk.controllers.IAdServerSettingsAdapter;
import de.guj.ems.mobile.sdk.controllers.IOnAdEmptyListener;
import de.guj.ems.mobile.sdk.controllers.IOnAdErrorListener;
import de.guj.ems.mobile.sdk.controllers.IOnAdSuccessListener;
import de.guj.ems.mobile.sdk.controllers.OptimobileDelegator;
import de.guj.ems.mobile.sdk.util.AppContext;
import de.guj.ems.mobile.sdk.util.Connectivity;
import de.guj.ems.mobile.sdk.util.SdkLog;
import de.guj.ems.mobile.sdk.util.UserAgentHelper;

/**
 * The webview uses as container to display an ad. Derived from the ORMMA
 * reference implementaton of an ad view container.
 * 
 * This class adds folowing capabilites to the reference implementation: -
 * loading data with an asynchronous HTTP request - initializing the view from
 * XML by passing a resource ID - adding custom view-specific parameters to a
 * placement's ad request (runtime) - adding matching or non-matching keywords
 * to a placement's ad request (runtime) - adding the javascript interface
 * EMSInterface to the view
 * 
 * ONLY USE THIS CLASS IF YOU WANT TO ADD THE VIEW PROGRAMMATICALLY INSTEAD OF
 * DEFINING IT WITHIN A LAYOUT.XML FILE!
 * 
 * @author stein16
 * 
 */
public class GuJEMSAdView extends OrmmaView implements
		AdResponseHandler {

	private Handler handler = new Handler();

	private IAdServerSettingsAdapter settings;

	private final String TAG = "GuJEMSAdView";

	/**
	 * Initialize view without configuration
	 * 
	 * @param context
	 *            android application context
	 */
	public GuJEMSAdView(Context context) {
		super(context);
		this.preLoadInitialize(context, null);
	}

	/**
	 * Initialize view with attribute set (this is the common constructor)
	 * 
	 * @param context
	 *            android application context
	 * @param resId
	 *            resource ID of the XML layout file to inflate from
	 */
	public GuJEMSAdView(Context context, AttributeSet set) {
		super(context, set);
		this.preLoadInitialize(context, set);
		this.load();
	}

	/**
	 * Initialize view from XML
	 * 
	 * @param context
	 *            android application context
	 * @param resId
	 *            resource ID of the XML layout file to inflate from
	 */
	public GuJEMSAdView(Context context, int resId) {
		super(context);
		AttributeSet attrs = inflate(resId);
		this.preLoadInitialize(context,attrs);
		this.handleInflatedLayout(attrs);
		this.load();
	}

	/**
	 * Initialize view from XML and add any custom parameters to the request
	 * 
	 * @param context
	 *            android application context
	 * @param customParams
	 *            map of custom param names and thiur values
	 * @param resId
	 *            resource ID of the XML layout file to inflate from
	 */
	public GuJEMSAdView(Context context, Map<String, ?> customParams, int resId) {
		super(context);
		AttributeSet attrs = inflate(resId);
		this.preLoadInitialize(context, attrs);
		this.addCustomParams(customParams);
		this.handleInflatedLayout(attrs);
		this.load();
	}

	/**
	 * Initialize view from XML and add matching or non-matching keywords as
	 * well as any custom parameters to the request
	 * 
	 * @param context
	 *            android application context
	 * @param customParams
	 *            map of custom param names and their values
	 * @param kws
	 *            matching keywords
	 * @param nkws
	 *            non-matching keywords
	 * @param resId
	 *            resource ID of the XML layout file to inflate from
	 */
	public GuJEMSAdView(Context context, Map<String, ?> customParams,
			String[] kws, String nkws[], int resId) {
		super(context);
		AttributeSet attrs = inflate(resId);
		this.preLoadInitialize(context, attrs, kws, nkws);
		this.addCustomParams(customParams);
		this.handleInflatedLayout(attrs);
		this.load();
	}

	/**
	 * Initialize view from XML and add matching or non-matching keywords
	 * 
	 * @param context
	 *            android application context
	 * @param kws
	 *            matching keywords
	 * @param nkws
	 *            non-matching keywords
	 * @param resId
	 *            resource ID of the XML layout file to inflate from
	 */
	public GuJEMSAdView(Context context, String[] kws, String nkws[], int resId) {
		super(context);
		AttributeSet attrs = inflate(resId);
		this.preLoadInitialize(context, attrs, kws, nkws);
		this.handleInflatedLayout(attrs);
		this.load();
	}

	private void handleInflatedLayout(AttributeSet attrs) {
		int w = attrs.getAttributeIntValue("http://schemas.android.com/apk/res/android", "layout_width", ViewGroup.LayoutParams.MATCH_PARENT);
		int h = attrs.getAttributeIntValue("http://schemas.android.com/apk/res/android", "layout_height", ViewGroup.LayoutParams.WRAP_CONTENT);
		String bk = attrs.getAttributeValue("http://schemas.android.com/apk/res/android", "background");
		setLayoutParams(new ViewGroup.LayoutParams(w, h));
		if (bk != null) {
			setBackgroundColor(Color.parseColor(bk));
		}
	}
	
	private void addCustomParams(Map<String, ?> params) {
		if (params != null) {
			Iterator<String> mi = params.keySet().iterator();
			while (mi.hasNext()) {
				String param = mi.next();
				Object value = params.get(param);
				if (value.getClass().equals(String.class)) {
					this.settings.addCustomRequestParameter(param, (String) value);
				} else if (value.getClass().equals(Double.class)) {
					this.settings.addCustomRequestParameter(param,
							((Double) value).doubleValue());
				} else if (value.getClass().equals(Integer.class)) {
					this.settings.addCustomRequestParameter(param,
							((Integer) value).intValue());
				} else {
					SdkLog.e(TAG,
							"Unknown object in custom params. Only String, Integer, Double allowed.");
				}
			}
		}
		else {
			SdkLog.w(TAG, "Custom params constructor used with null-array.");
		}
	}

	public Handler getHandler() {
		return handler;
	}

	private AttributeSet inflate(int resId) {
		AttributeSet as = null;
		Resources r = getResources();
		XmlResourceParser parser = r.getLayout(resId);

		
		
		int state = 0;
		do {
			try {
				state = parser.next();
			} catch (XmlPullParserException e1) {
				e1.printStackTrace();
			} catch (IOException e1) {
				e1.printStackTrace();
			}
			if (state == XmlPullParser.START_TAG) {
				if (parser.getName().equals(
						"de.guj.ems.mobile.sdk.views.GuJEMSAdView")) {
					as = Xml.asAttributeSet(parser);
					break;
				} else {
					SdkLog.d(TAG, parser.getName());
				}
			}
		} while (state != XmlPullParser.END_DOCUMENT);

		
		return as;
	}

	private final void load() {

		if (settings != null) {

			// Construct request URL
			final String url = this.settings.getRequestUrl();
			if (Connectivity.isOnline()) {

				SdkLog.i(TAG, "ems_adcall: START async. AdServer request");
				SdkLog.d(TAG, "ems_adcall: url = " + url);
				new AdServerAccess(UserAgentHelper.getUserAgent(), this)
						.execute(new String[] { url });
			}
			// Do nothing if offline
			else {
				SdkLog.i(TAG,
						"ems_adcall: No network connection - not requesting ads.");
				setVisibility(GONE);
				processError("No network connection.");
			}
		} else {
			SdkLog.w(TAG, "AdView has no settings.");
		}
	}

	private void preLoadInitialize(Context context, AttributeSet set) {
		this.addJavascriptInterface(new EMSInterface(), "emsmobile");
		if (set != null && !isInEditMode()) {
			this.settings = new AmobeeSettingsAdapter(context, set);
		} else if (isInEditMode()) {
			// TODO does this work?!
			//loadUrl("file:///android_asset/defaultad.html", false, null);
			super.loadDataWithBaseURL("file:///android_asset/", "<!DOCTYPE html><html><head><title>G+J EMS AdView</title></head><body><img src=\"defaultad.png\"></body></html>", "text/html", "utf-8", null);			
			setVisibility(VISIBLE);
		}
	}

	private void preLoadInitialize(Context context, AttributeSet set,
			String[] kws, String[] nkws) {
		this.addJavascriptInterface(new EMSInterface(), "emsmobile");
		if (set != null && !isInEditMode()) {
			this.settings = new AmobeeSettingsAdapter(context, set, kws, nkws);
		} else if (isInEditMode()) {
			//loadUrl("file:///android_asset/defaultad.html", false, null);
			super.loadDataWithBaseURL("file:///android_asset/", "<!DOCTYPE html><html><head><title>G+J EMS AdView</title></head><body><img src=\"defaultad.png\"></body></html>", "text/html", "utf-8", null);
			//loadUrl("file:///android_asset/defaultad.html");
			setVisibility(VISIBLE);
		}
	}

	@Override
	public void processError(String msg) {
		SdkLog.w(
				TAG,
				"The following error occured and is being handled by the appropriate listener if available.");
		SdkLog.e(TAG, msg);
		if (this.settings.getOnAdErrorListener() != null) {
			this.settings.getOnAdErrorListener().onAdError(msg);
		}
	}

	@Override
	public void processError(String msg, Throwable t) {
		SdkLog.w(
				TAG,
				"The following error occured and is being handled by the appropriate listener if available.");
		if (msg != null && msg.length() > 0) {
			SdkLog.e(TAG, msg);
		} else {
			SdkLog.e(TAG, "Exception: ", t);
		}
		if (this.settings.getOnAdErrorListener() != null) {
			this.settings.getOnAdErrorListener().onAdError(msg, t);
		}
	}

	public final void processResponse(String response) {
		try {
			if (response != null && response.length() > 0) {
				setTimeoutRunnable(new TimeOutRunnable());
				loadData(response, "text/html", "utf-8");
				SdkLog.i(TAG, "Ad found and loading...");
				if (this.settings.getOnAdSuccessListener() != null) {
					this.settings.getOnAdSuccessListener().onAdSuccess();
				}
			} else {
				setVisibility(GONE);
				if (this.settings.getDirectBackfill() != null) {
					try {
						SdkLog.i(TAG, "Passing to optimobile delegator.");
						OptimobileDelegator optimobileDelegator = new OptimobileDelegator(
								AppContext.getContext(), this, settings);
						((ViewGroup) getParent())
								.addView(optimobileDelegator
										.getOptimobileView(),
										((ViewGroup) getParent())
												.indexOfChild(this) + 1);
						optimobileDelegator.getOptimobileView().update();

					} catch (Exception e) {
						if (this.settings.getOnAdErrorListener() != null) {
							this.settings.getOnAdErrorListener().onAdError(
									"Error delegating to optimobile", e);
						} else {
							SdkLog.e(TAG, "Error delegating to optimobile", e);
						}
					}
				} else {
					if (this.settings.getOnAdEmptyListener() != null) {
						this.settings.getOnAdEmptyListener().onAdEmpty();
					} else {
						SdkLog.i(TAG, "No valid ad found.");
					}
				}
			}
			SdkLog.i(TAG, "FINISH async. AdServer request");
		} catch (Exception e) {
			processError("Error loading ad", e);
		}
	}

	@Override
	public void reload() {
		if (settings != null) {
			super.clearView();
			setVisibility(View.GONE);

			// Construct request URL
			final String url = this.settings.getRequestUrl();
			if (Connectivity.isOnline()) {

				SdkLog.i(TAG, "ems_adcall: START async. AdServer request");
				SdkLog.d(TAG, "ems_adcall: url = " + url);
				new AdServerAccess(UserAgentHelper.getUserAgent(), this)
						.execute(new String[] { url });
			}
			// Do nothing if offline
			else {
				SdkLog.i(TAG,
						"ems_adcall: No network connection - not requesting ads.");
				setVisibility(GONE);
				processError("No network connection.");
			}
		} else {
			SdkLog.w(TAG, "AdView has no settings.");
		}
	}

	public void setOnAdEmptyListener(IOnAdEmptyListener l) {
		this.settings.setOnAdEmptyListener(l);
	}

	public void setOnAdErrorListener(IOnAdErrorListener l) {
		this.settings.setOnAdErrorListener(l);
	}

	public void setOnAdSuccessListener(IOnAdSuccessListener l) {
		this.settings.setOnAdSuccessListener(l);
	}
	
}