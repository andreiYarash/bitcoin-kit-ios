Pod::Spec.new do |s|
  s.name             = 'LitecoinKit.swift'
  s.module_name      = 'LitecoinKit'
  s.version          = '0.18'
  s.summary          = 'Litecoin library for Swift.'

  s.description      = <<-DESC
LitecoinKit implements Litecoin protocol in Swift.
                       DESC

  s.homepage         = 'https://github.com/horizontalsystems/bitcoin-kit-ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Horizontal Systems' => 'hsdao@protonmail.ch' }
  s.source           = { git: 'https://github.com/horizontalsystems/bitcoin-kit-ios.git', tag: "litecoin-#{s.version}" }
  s.social_media_url = 'http://horizontalsystems.io/'

  s.ios.deployment_target = '13.0'
  s.swift_version = '5'

  s.source_files = 'LitecoinKit/Classes/**/*'
  s.resource_bundle = { 'LitecoinKit' => 'LitecoinKit/Assets/Checkpoints/*' }

  s.dependency 'BitcoinCore.swift', '~> 0.18'
  s.dependency 'OpenSslKit.swift', '~> 1.0'
  s.dependency 'Secp256k1Kit.swift', '~> 1.0'

  s.dependency 'ObjectMapper', '~> 4.0'
  s.dependency 'RxSwift', '~> 6.0'
  s.dependency 'BigInt', '~> 5.0'
  s.dependency 'GRDB.swift', '~> 5.0'
end
