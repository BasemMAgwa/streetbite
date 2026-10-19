package com.streetbite.qa;

import io.appium.java_client.AppiumBy;
import org.junit.jupiter.api.Assumptions;
import org.junit.jupiter.api.Test;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;

import static org.junit.jupiter.api.Assertions.assertTrue;

public class LoginTest extends BaseTest {
  private WebElement email() {
    return wait.until(driver -> driver.findElements(AppiumBy.className("android.widget.EditText")).size() >= 2
        ? driver.findElements(AppiumBy.className("android.widget.EditText")).get(0) : null);
  }

  private WebElement password() {
    return driver.findElements(AppiumBy.className("android.widget.EditText")).get(1);
  }

  private void submit() {
    wait.until(ExpectedConditions.elementToBeClickable(AppiumBy.accessibilityId("Log in"))).click();
  }

  @Test
  void validLoginOpensHome() {
    String user = setting("qa.email", "QA_TEST_EMAIL", "");
    String secret = setting("qa.password", "QA_TEST_PASSWORD", "");
    Assumptions.assumeTrue(!user.isBlank() && !secret.isBlank(),
        "Set QA_TEST_EMAIL and QA_TEST_PASSWORD for an authorized Firebase account.");
    email().click();
    email().sendKeys(user);
    password().click();
    password().sendKeys(secret);
    submit();
    assertTrue(wait.until(ExpectedConditions.visibilityOfElementLocated(AppiumBy.accessibilityId("Live Menu"))).isDisplayed());
  }

  @Test
  void invalidCredentialsStayOnLogin() {
    email().click();
    email().sendKeys("qa.invalid@example.com");
    assertTrue(email().getText().contains("qa.invalid@example.com"), "Email entry should reach the Flutter field.");
    password().click();
    password().sendKeys("incorrect-password-123");
    submit();
    assertTrue(wait.until(ExpectedConditions.visibilityOfElementLocated(
        AppiumBy.accessibilityId("Email or password is incorrect."))).isDisplayed());
    assertTrue(driver.findElement(AppiumBy.accessibilityId("Log in")).isDisplayed());
  }

  @Test
  void emptyFieldsShowValidationErrors() {
    email();
    submit();
    assertTrue(wait.until(ExpectedConditions.visibilityOfElementLocated(
        AppiumBy.accessibilityId("Enter your email address"))).isDisplayed());
    assertTrue(driver.findElement(AppiumBy.accessibilityId("Enter your password")).isDisplayed());
  }
}
