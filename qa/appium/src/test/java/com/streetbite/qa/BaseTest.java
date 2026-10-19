package com.streetbite.qa;

import io.appium.java_client.android.AndroidDriver;
import io.appium.java_client.android.options.UiAutomator2Options;
import java.io.IOException;
import java.net.URI;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.Duration;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.TestInfo;
import org.openqa.selenium.OutputType;
import org.openqa.selenium.support.ui.WebDriverWait;

public abstract class BaseTest {
  protected AndroidDriver driver;
  protected WebDriverWait wait;

  @BeforeEach
  void setUp() throws Exception {
    String apk = setting("appium.apk", "STREETBITE_APK", "../../build/app/outputs/flutter-apk/app-release.apk");
    Path apkPath = Path.of(apk).toAbsolutePath().normalize();
    if (!Files.isRegularFile(apkPath)) {
      throw new IllegalStateException("APK not found: " + apkPath + ". Build it with flutter build apk --release.");
    }
    UiAutomator2Options options = new UiAutomator2Options()
        .setDeviceName("StreetBite Android")
        .setApp(apkPath.toString())
        .setAppPackage("com.example.streetbite")
        .setAutomationName("UiAutomator2")
        .setFullReset(true)
        .setNewCommandTimeout(Duration.ofSeconds(120));
    // The app requests location at startup; dismissing that OS prompt keeps Login reachable.
    options.setCapability("appium:autoGrantPermissions", true);
    // Some vendor builds deny WRITE_SECURE_SETTINGS while Appium adjusts Android hidden-API policy.
    options.setCapability("appium:ignoreHiddenApiPolicyError", true);
    String udid = setting("appium.udid", "ANDROID_UDID", "");
    if (!udid.isBlank()) options.setUdid(udid);
    String server = setting("appium.server", "APPIUM_SERVER", "http://127.0.0.1:4723");
    driver = new AndroidDriver(URI.create(server).toURL(), options);
    wait = new WebDriverWait(driver, Duration.ofSeconds(30));
  }

  @AfterEach
  void tearDown(TestInfo info) throws IOException {
    if (driver == null) return;
    try {
      Path evidence = Path.of("target", "screenshots");
      Files.createDirectories(evidence);
      String name = info.getTestMethod().map(method -> method.getName()).orElse("test");
      String stamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss"));
      Files.write(evidence.resolve(name + "_" + stamp + ".png"), driver.getScreenshotAs(OutputType.BYTES));
    } finally {
      driver.quit();
    }
  }

  protected static String setting(String property, String environment, String fallback) {
    String value = System.getProperty(property);
    if (value == null || value.isBlank()) value = System.getenv(environment);
    return value == null || value.isBlank() ? fallback : value;
  }
}
