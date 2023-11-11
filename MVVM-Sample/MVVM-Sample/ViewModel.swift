
import Foundation
import RxSwift
import RxCocoa
import Combine

// protocolでinputとoutputを定義しておく(入力なのか出力なのか分かりやすくするため)
protocol ViewModelInput {
    var buttonDidTap_Rx: PublishRelay<Void> { get }
    var buttonDidTap_Combine: PassthroughSubject<Void,Never> { get }
}

protocol ViewModelOutput {
    var showText_Rx: PublishRelay<String> { get }
    var showText_Combine: PassthroughSubject<String,Never> { get }
}

protocol ViewModelType {
    var input: ViewModelInput { get }
    var output: ViewModelOutput { get }
}

// MARK: -
///PublishRelayのざっくりした説明 https://qiita.com/pecoms/items/55a8db8feba9242ef50e
///PassthroughSubjectのざっくりした説明 https://tech.amefure.com/swift-combine-passthroughsubject
/// 両方とも、「値が流れてきたことを検知するモノ」というイメージ


/// ロジックは全てViewModelに閉じ込める(APIなどの処理がある場合はViewModelで処理する)
final class ViewModel: ViewModelInput, ViewModelOutput, ViewModelType {
    
    var input: ViewModelInput { return self }
    var output: ViewModelOutput { return self }
    
    // input(ボタンのタップを検知する)
    let buttonDidTap_Rx = PublishRelay<Void>()
    let buttonDidTap_Combine = PassthroughSubject<Void, Never>()

    // output(UIに表示したいものを出力)
    let showText_Rx = PublishRelay<String>()
    let showText_Combine = PassthroughSubject<String, Never>()
    
    // Private
    private let disposeBug = DisposeBag()
    private var cancellable = Set<AnyCancellable>()
    
    
    init() {
        // initでバインディング
        bind()
    }
    
    private func bind() {
        
        // タップで値(Void)が流れてきたので、両者ともそれをStringに変換して出力している
        
        buttonDidTap_Rx
            .map { "Rx" }
            .bind(to: output.showText_Rx)
            .disposed(by: disposeBug)
        
        buttonDidTap_Combine
            .map { "Combine" }
            .sink { [weak self] text in
                self?.output.showText_Combine.send(text)
            }
            .store(in: &cancellable)
    }
    
}
