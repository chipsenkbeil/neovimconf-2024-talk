-- Taken from https://github.com/chipsenkbeil/org-roam.nvim/blob/main/lua/webview.utils/emitter.lua

---Implementation of a manager of events that can both store callbacks and trigger events.
---@class webview.utils.Emitter
---@field private __event_handlers table<any, table<fun(), fun()>>
---@field private __event_handlers_once table<any, table<fun(), fun()>>
local M = {}
M.__index = M

---Creates a new instance of the emitter.
---@return webview.utils.Emitter
function M:new()
    local instance = {}
    setmetatable(instance, M)
    instance.__event_handlers = {}
    instance.__event_handlers_once = {}
    return instance
end

---@param handler fun(...): any
local function call_handler(handler, ...)
    local ok, err = pcall(handler, ...)
    if not ok then
        vim.schedule(function()
            vim.api.nvim_err_writeln(err)
        end)
    end
end

---Emits the specified event to trigger all associated handlers
---and passes all additional arguments to the handler.
---@param event any # event to emit
---@param ... any # additional arguments to get passed to handlers
---@return webview.utils.Emitter
function M:emit(event, ...)
    if self.__event_handlers[event] then
        for handler in pairs(self.__event_handlers[event]) do
            call_handler(handler, ...)
        end
    end
    if self.__event_handlers_once[event] then
        for handler in pairs(self.__event_handlers_once[event]) do
            call_handler(handler, ...)
            self.__event_handlers_once[event][handler] = nil
        end
    end
    return self
end

---Registers a callback to be invoked when the specified event is emitted.
---More than one handler can be associated with the same event.
---@param event any # event to receive
---@param handler fun(...) # callback to trigger on event
---@return webview.utils.Emitter
function M:on(event, handler)
    if not self.__event_handlers[event] then
        self.__event_handlers[event] = {}
    end
    self.__event_handlers[event][handler] = handler
    return self
end

---Registers a callback to be invoked when the specified event is emitted.
---Upon being triggered, the handler will be removed.
---
---More than one handler can be associated with the same event.
---@param event any # event to receive
---@param handler fun(...) # callback to trigger on event
---@return webview.utils.Emitter
function M:once(event, handler)
    if not self.__event_handlers_once[event] then
        self.__event_handlers_once[event] = {}
    end
    self.__event_handlers_once[event][handler] = handler
    return self
end

---Unregisters the callback for the specified event.
---@param event any # event whose handler to remove
---@param handler fun(...) # handler to remove
---@return webview.utils.Emitter
function M:off(event, handler)
    if self.__event_handlers[event] then
        self.__event_handlers[event][handler] = nil
    end
    if self.__event_handlers_once[event] then
        self.__event_handlers_once[event][handler] = nil
    end
    return self
end

---@private
function M:__clear_event_handlers()
    self.__event_handlers = {}
    self.__event_handlers_once = {}
end

return M
