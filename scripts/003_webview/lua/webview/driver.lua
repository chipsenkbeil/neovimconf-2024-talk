---@alias webview.driver.SendFn fun(command:string, data?:table):webview.utils.Promise

---@class webview.Driver
---@field private __send webview.driver.SendFn
local M = {}
M.__index = M

---Creates a new driver instance.
---@param opts {send:webview.driver.SendFn}
---@return webview.Firefox
function M:new(opts)
    opts = opts or {}

    local instance = {}
    setmetatable(instance, M)

    instance.__send = opts.send

    return instance
end

-------------------------------------------------------------------------------
-- WEB DRIVER SERVICE
-------------------------------------------------------------------------------

---Navigates to the given URL, waiting for the page to load before returning.
---
---The document is considered successfully loaded when the DOMContentLoaded
---event on the frame element associated with the current window triggers and
---document.readyState is "complete".
---
---1. `url` representing the URL to navigate to.
---
---@param opts {url:string}
---@return webview.utils.Promise<nil>
function M:navigate(opts)
    ---@param msg {value:nil}
    return self.__send("WebDriver:Navigate", opts):next(function(msg)
        return msg.value
    end)
end

---Starts a new session on the browser.
---
---1. `sessionId` (optional) will override the one created by the browser.
---2. `capabilities` (optional) will process these (??).
---
---@param opts? {sessionId?:string, capabilities?:table<string, any>}
---@return webview.utils.Promise<{sessionId:string, capabilities:table<string, any>}>
function M:new_session(opts)
    return self.__send("WebDriver:NewSession", opts)
end

---Takes a screenshot of the browser, returning the base64 encoded image.
---
---1. `id` (optional) will take a screenshot of the referenced web element;
---   otherwise, will take a screenshot of the entire document.
---2. `full` (optional) if true, takes screenshot of entire document. Only
---   considered when `id` is not specified. Defaults to true.
---3. `hash` (optional) if true, requests a SHA-256 hash of the encoded image.
---   Defaults to false.
---4. `scroll` (optional) if true, scrolls to element if `id` provided.
---   Defaults to true.
---
---@param opts? {id?:string, full?:boolean, hash?:boolean, scroll?:boolean}
---@return webview.utils.Promise<string>
function M:take_screenshot(opts)
    ---@param msg {value:string}
    return self.__send("WebDriver:TakeScreenshot", opts):next(function(msg)
        return msg.value
    end)
end

-------------------------------------------------------------------------------
-- REFERENCE
-------------------------------------------------------------------------------

-- From https://github.com/cliqz-oss/browser-f/blob/master/mozilla-release/testing/marionette/driver.js#3822
-- References to Mozilla's driver.js are broken as they seem to have switched to Python for their driver.
--
-- // Marionette service
--   "Marionette:AcceptConnections": GeckoDriver.prototype.acceptConnections,
--   "Marionette:GetContext": GeckoDriver.prototype.getContext,
--   "Marionette:GetScreenOrientation": GeckoDriver.prototype.getScreenOrientation,
--   "Marionette:GetWindowType": GeckoDriver.prototype.getWindowType,
--   "Marionette:Quit": GeckoDriver.prototype.quit,
--   "Marionette:SetContext": GeckoDriver.prototype.setContext,
--   "Marionette:SetScreenOrientation": GeckoDriver.prototype.setScreenOrientation,
--   "Marionette:ActionChain": GeckoDriver.prototype.actionChain, // bug 1354578, legacy actions
--   "Marionette:MultiAction": GeckoDriver.prototype.multiAction, // bug 1354578, legacy actions
--   "Marionette:SingleTap": GeckoDriver.prototype.singleTap,
--
--   // Addon service
--   "Addon:Install": GeckoDriver.prototype.installAddon,
--   "Addon:Uninstall": GeckoDriver.prototype.uninstallAddon,
--
--   // L10n service
--   "L10n:LocalizeEntity": GeckoDriver.prototype.localizeEntity,
--   "L10n:LocalizeProperty": GeckoDriver.prototype.localizeProperty,
--
--   // Reftest service
--   "reftest:setup": GeckoDriver.prototype.setupReftest,
--   "reftest:run": GeckoDriver.prototype.runReftest,
--   "reftest:teardown": GeckoDriver.prototype.teardownReftest,
--
--   // WebDriver service
--   "WebDriver:AcceptAlert": GeckoDriver.prototype.acceptDialog,
--   "WebDriver:AcceptDialog": GeckoDriver.prototype.acceptDialog, // deprecated, but used in geckodriver (see also bug 1495063)
--   "WebDriver:AddCookie": GeckoDriver.prototype.addCookie,
--   "WebDriver:Back": GeckoDriver.prototype.goBack,
--   "WebDriver:CloseChromeWindow": GeckoDriver.prototype.closeChromeWindow,
--   "WebDriver:CloseWindow": GeckoDriver.prototype.close,
--   "WebDriver:DeleteAllCookies": GeckoDriver.prototype.deleteAllCookies,
--   "WebDriver:DeleteCookie": GeckoDriver.prototype.deleteCookie,
--   "WebDriver:DeleteSession": GeckoDriver.prototype.deleteSession,
--   "WebDriver:DismissAlert": GeckoDriver.prototype.dismissDialog,
--   "WebDriver:ElementClear": GeckoDriver.prototype.clearElement,
--   "WebDriver:ElementClick": GeckoDriver.prototype.clickElement,
--   "WebDriver:ElementSendKeys": GeckoDriver.prototype.sendKeysToElement,
--   "WebDriver:ExecuteAsyncScript": GeckoDriver.prototype.executeAsyncScript,
--   "WebDriver:ExecuteScript": GeckoDriver.prototype.executeScript,
--   "WebDriver:FindElement": GeckoDriver.prototype.findElement,
--   "WebDriver:FindElements": GeckoDriver.prototype.findElements,
--   "WebDriver:Forward": GeckoDriver.prototype.goForward,
--   "WebDriver:FullscreenWindow": GeckoDriver.prototype.fullscreenWindow,
--   "WebDriver:GetActiveElement": GeckoDriver.prototype.getActiveElement,
--   "WebDriver:GetActiveFrame": GeckoDriver.prototype.getActiveFrame,
--   "WebDriver:GetAlertText": GeckoDriver.prototype.getTextFromDialog,
--   "WebDriver:GetCapabilities": GeckoDriver.prototype.getSessionCapabilities,
--   "WebDriver:GetChromeWindowHandle":
--     GeckoDriver.prototype.getChromeWindowHandle,
--   "WebDriver:GetChromeWindowHandles":
--     GeckoDriver.prototype.getChromeWindowHandles,
--   "WebDriver:GetCookies": GeckoDriver.prototype.getCookies,
--   "WebDriver:GetCurrentChromeWindowHandle":
--     GeckoDriver.prototype.getChromeWindowHandle,
--   "WebDriver:GetCurrentURL": GeckoDriver.prototype.getCurrentUrl,
--   "WebDriver:GetElementAttribute": GeckoDriver.prototype.getElementAttribute,
--   "WebDriver:GetElementCSSValue":
--     GeckoDriver.prototype.getElementValueOfCssProperty,
--   "WebDriver:GetElementProperty": GeckoDriver.prototype.getElementProperty,
--   "WebDriver:GetElementRect": GeckoDriver.prototype.getElementRect,
--   "WebDriver:GetElementTagName": GeckoDriver.prototype.getElementTagName,
--   "WebDriver:GetElementText": GeckoDriver.prototype.getElementText,
--   "WebDriver:GetPageSource": GeckoDriver.prototype.getPageSource,
--   "WebDriver:GetTimeouts": GeckoDriver.prototype.getTimeouts,
--   "WebDriver:GetTitle": GeckoDriver.prototype.getTitle,
--   "WebDriver:GetWindowHandle": GeckoDriver.prototype.getWindowHandle,
--   "WebDriver:GetWindowHandles": GeckoDriver.prototype.getWindowHandles,
--   "WebDriver:GetWindowRect": GeckoDriver.prototype.getWindowRect,
--   "WebDriver:IsElementDisplayed": GeckoDriver.prototype.isElementDisplayed,
--   "WebDriver:IsElementEnabled": GeckoDriver.prototype.isElementEnabled,
--   "WebDriver:IsElementSelected": GeckoDriver.prototype.isElementSelected,
--   "WebDriver:MinimizeWindow": GeckoDriver.prototype.minimizeWindow,
--   "WebDriver:MaximizeWindow": GeckoDriver.prototype.maximizeWindow,
--   "WebDriver:Navigate": GeckoDriver.prototype.get,
--   "WebDriver:NewSession": GeckoDriver.prototype.newSession,
--   "WebDriver:NewWindow": GeckoDriver.prototype.newWindow,
--   "WebDriver:PerformActions": GeckoDriver.prototype.performActions,
--   "WebDriver:Print": GeckoDriver.prototype.print,
--   "WebDriver:Refresh": GeckoDriver.prototype.refresh,
--   "WebDriver:ReleaseActions": GeckoDriver.prototype.releaseActions,
--   "WebDriver:SendAlertText": GeckoDriver.prototype.sendKeysToDialog,
--   "WebDriver:SetTimeouts": GeckoDriver.prototype.setTimeouts,
--   "WebDriver:SetWindowRect": GeckoDriver.prototype.setWindowRect,
--   "WebDriver:SwitchToFrame": GeckoDriver.prototype.switchToFrame,
--   "WebDriver:SwitchToParentFrame": GeckoDriver.prototype.switchToParentFrame,
--   "WebDriver:SwitchToShadowRoot": GeckoDriver.prototype.switchToShadowRoot,
--   "WebDriver:SwitchToWindow": GeckoDriver.prototype.switchToWindow,
--   "WebDriver:TakeScreenshot": GeckoDriver.prototype.takeScreenshot,

return M
