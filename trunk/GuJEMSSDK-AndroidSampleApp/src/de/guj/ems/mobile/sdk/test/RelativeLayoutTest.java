/*  Copyright (c) 2012 G+J EMS GmbH.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */
package de.guj.ems.mobile.sdk.test;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;

public class RelativeLayoutTest extends Activity {

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.relative_layout);
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		MenuInflater inflater = getMenuInflater();
		inflater.inflate(R.menu.menu, menu);
		return true;
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		Intent target = MenuItemHelper.getTargetIntent(
				getApplicationContext(), item.getItemId());
		if (target != null) {
			sendBroadcast(target);
		}
		return true;
	}

	public void onInterstitialAdError(String msg) {
		System.out.println(msg);
	}
	
	public void onInterstitialAdError(String msg, Throwable t) {
		System.out.println(t.toString());
	}
}