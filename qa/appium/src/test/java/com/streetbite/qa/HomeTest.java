package com.streetbite.qa;

import io.appium.java_client.AppiumBy;
import java.util.Map;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Assumptions;
import org.junit.jupiter.api.Test;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

public class HomeTest extends BaseTest {
  @BeforeEach
  void logIn() {
    String user = setting("qa.email", "QA_TEST_EMAIL", "");
    String secret = setting("qa.password", "QA_TEST_PASSWORD", "");
    Assumptions.assumeTrue(!user.isBlank() && !secret.isBlank(),
        "Set QA_TEST_EMAIL and QA_TEST_PASSWORD for an authorized Firebase account.");
    wait.until(driver -> driver.findElements(AppiumBy.className("android.widget.EditText")).size() >= 2);
    driver.findElements(AppiumBy.className("android.widget.EditText")).get(0).click();
    driver.findElements(AppiumBy.className("android.widget.EditText")).get(0).sendKeys(user);
    driver.findElements(AppiumBy.className("android.widget.EditText")).get(1).click();
    driver.findElements(AppiumBy.className("android.widget.EditText")).get(1).sendKeys(secret);
    driver.findElement(AppiumBy.accessibilityId("Log in")).click();
    wait.until(ExpectedConditions.visibilityOfElementLocated(AppiumBy.accessibilityId("Live Menu")));
    wait.until(driver -> !driver.findElements(AppiumBy.accessibilityId("Add to cart")).isEmpty()
        || !driver.findElements(AppiumBy.accessibilityId("Try again")).isEmpty());
    assertTrue(driver.findElements(AppiumBy.accessibilityId("Try again")).isEmpty(),
        "Home menu could not load; check network and TheMealDB.");
    scrollDown();
    wait.until(ExpectedConditions.visibilityOfElementLocated(AppiumBy.accessibilityId("Add to cart")));
  }

  private void scrollDown() {
    var size = driver.manage().window().getSize();
    driver.executeScript("mobile: scrollGesture", Map.of(
        "left", size.width / 10, "top", size.height / 5,
        "width", size.width * 8 / 10, "height", size.height * 6 / 10,
        "direction", "down", "percent", 0.7));
  }

  @Test
  void scrollsThroughMealGrid() {
    String firstPage = driver.getPageSource();
    scrollDown();
    boolean moved = wait.until(driver -> !driver.getPageSource().equals(firstPage));
    assertTrue(moved, "Home content should move when scrolled.");
    assertFalse(driver.findElements(AppiumBy.accessibilityId("Add to cart")).isEmpty(),
        "Meal cards should remain accessible after scrolling.");
  }

  @Test
  void addingMealShowsSnackBar() {
    WebElement add = wait.until(ExpectedConditions.elementToBeClickable(AppiumBy.accessibilityId("Add to cart")));
    add.click();
    assertTrue(wait.until(ExpectedConditions.visibilityOfElementLocated(
        AppiumBy.accessibilityId("Added to cart"))).isDisplayed());
  }
}
