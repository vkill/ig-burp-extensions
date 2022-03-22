require 'java'
require 'net/http'
require 'uri'

java_import 'burp.IBurpExtender'
java_import 'burp.IHttpListener'

class BurpExtender
  include IBurpExtender, IHttpListener

  def registerExtenderCallbacks(callbacks)
    @callbacks = callbacks
    @helpers = callbacks.getHelpers

    callbacks.setExtensionName("IG - Profile - About this account")
    callbacks.registerHttpListener(self)
  end

  def processHttpMessage(toolFlag, messageIsRequest, messageInfo)
    return if @callbacks.getToolName(toolFlag) != 'Proxy'

    return if messageIsRequest

    # 
    req = @helpers.analyzeRequest(messageInfo)

    if req.getMethod() == 'POST' && req.getUrl().to_s.end_with?('/api/v1/bloks/apps/com.instagram.interactions.about_this_account/')
      res_bytes = messageInfo.getResponse()
      res = @helpers.analyzeResponse(res_bytes)

      if res.getStatusCode() == 200
        res_body_offset = res.getBodyOffset()
        res_body_bytes = res_bytes[res_body_offset,res_bytes.count]

        res = Net::HTTP.post URI('https://httpbin.org/post'), res_body_bytes.to_s, "Content-Type" => "application/json"
        pp [:xx, res]
      end
    end

  end
end
