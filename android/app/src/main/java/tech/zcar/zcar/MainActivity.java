package tech.zcar.zcar;

import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.text.TextUtils;
import android.util.Base64;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;

import java.io.ByteArrayOutputStream;
import java.io.PrintStream;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity implements MethodChannel.MethodCallHandler {
    private MethodChannel methodChannel;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        methodChannel = new MethodChannel(flutterEngine.getDartExecutor(), "zcar");
        methodChannel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        switch (call.method) {
            case "listAllApps":
                getAllPackages(getApplicationContext(), result);
                break;
            case "runApp":
                runApp(getApplicationContext(), call.argument("packageName"), result);
                break;
            default:
                result.error("unimplemented", "unimplemented platform method", call.method);
                break;
        }
    }

    private void runApp(Context context, String packageName, MethodChannel.Result result) {
        try {
            PackageManager pm = context.getPackageManager();
            Intent intent = new Intent(Intent.ACTION_MAIN);
            intent.addCategory(Intent.CATEGORY_LAUNCHER);
            intent.setFlags(Intent.FLAG_ACTIVITY_RESET_TASK_IF_NEEDED | Intent.FLAG_ACTIVITY_NEW_TASK);

            String mainAct = "";
            List<ResolveInfo> infos = pm.queryIntentActivities(intent, PackageManager.GET_ACTIVITIES);
            for (ResolveInfo info : infos) {
                if (info.activityInfo.packageName.equals(packageName)) {
                    mainAct = info.activityInfo.name;
                    break;
                }
            }
            intent.setComponent(new ComponentName(packageName, mainAct));
            context.startActivity(intent);
            result.success(null);
        } catch (Exception e) {
            platformError(e, result);
        }
    }

    private void getAllPackages(Context context, MethodChannel.Result result) {
        try {
            Intent intent = new Intent();
            intent.setAction(Intent.ACTION_MAIN);
            intent.addCategory(Intent.CATEGORY_LAUNCHER);

            PackageManager pm = context.getPackageManager();
            List<ResolveInfo> infos = pm.queryIntentActivities(intent, PackageManager.MATCH_ALL);
            List<Map<String, Object>> resultList = new ArrayList<>();
            for (ResolveInfo info : infos) {
                if (info.activityInfo.packageName.equals(context.getPackageName())) {
                    continue;
                }
                Map<String, Object> r = new HashMap<>();
                r.put("name", info.loadLabel(pm).toString());
                r.put("packageName", info.activityInfo.packageName);
                byte[] iconData = new byte[0];
                Drawable iconD = info.loadIcon(pm);
                Bitmap icon = null;
                if (iconD instanceof BitmapDrawable && ((BitmapDrawable) iconD).getBitmap() != null) {
                    icon = ((BitmapDrawable) iconD).getBitmap();
                } else {
                    if (iconD.getIntrinsicWidth() <= 0 || iconD.getIntrinsicHeight() <= 0) {
                        icon = Bitmap.createBitmap(1, 1, Bitmap.Config.ARGB_8888);
                    } else {
                        icon = Bitmap.createBitmap(iconD.getIntrinsicWidth(), iconD.getIntrinsicHeight(), Bitmap.Config.ARGB_8888);
                    }
                    Canvas canvas = new Canvas(icon);
                    iconD.setBounds(0, 0, canvas.getWidth(), canvas.getHeight());
                    iconD.draw(canvas);
                }
                ByteArrayOutputStream baos = new ByteArrayOutputStream();
                icon.compress(Bitmap.CompressFormat.PNG, 100, baos);
                r.put("iconData", Base64.encodeToString(baos.toByteArray(), Base64.NO_WRAP));
                resultList.add(r);
            }
            result.success(resultList);
        } catch (Exception e) {
            platformError(e, result);
        }
    }

    private void platformError(Throwable e, MethodChannel.Result result) {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        String encoding = StandardCharsets.UTF_8.name();
        try (PrintStream ps = new PrintStream(baos, true, encoding)) {
            e.printStackTrace(ps);
            String details = baos.toString(encoding);
            result.error("platform_error", e.getMessage(), details);
        } catch (Exception notImportant) {}
    }
}
