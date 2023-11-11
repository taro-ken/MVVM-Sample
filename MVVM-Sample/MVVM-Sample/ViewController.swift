

import UIKit
import RxCocoa
import RxSwift
import Combine
import CombineCocoa

final class ViewController: UIViewController {
    
    @IBOutlet private weak var rxButton: UIButton!
    @IBOutlet private weak var combineButton: UIButton!
    @IBOutlet private weak var label: UILabel!
    
    private let viewModel = ViewModel()

    // 講読解除するゴミ箱的な役割("https://qiita.com/ta9yamakawa/items/0580799542a1f518a53f")
    private let disposeBug = DisposeBag()
    private var cancellable = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // ここでバインディングする
        bindInput()
        bindOutput()
    }
    
    // 入力に関するバインディング(UIからの入力をViewModelに伝達)
    private func bindInput() {
        
        rxButton.rx.tap
            .bind(to: viewModel.input.buttonDidTap_Rx)
            .disposed(by: disposeBug)
        
        combineButton.tapPublisher
            .sink { [weak self] in
                self?.viewModel.buttonDidTap_Combine.send(())
            }
            .store(in: &cancellable)
    }
    
    // 出力に関するバインディング(ViewModelから来た値をUIに表示)
    private func bindOutput() {
        
        viewModel.output
            .showText_Rx.bind(to: label.rx.text)
            .disposed(by: disposeBug)
        
        viewModel.output.showText_Combine
            .map { $0 }
            .assign(to: \.label.text, on: self)
            .store(in: &cancellable)
    }
}

