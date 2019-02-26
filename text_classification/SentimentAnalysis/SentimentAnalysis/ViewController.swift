//
//  ViewController.swift
//  SentimentAnalysis
//
//  Created by Vincent on 26/02/2019.
//  Copyright © 2019 Vincent. All rights reserved.
//

import UIKit
import NaturalLanguage

class ViewController: UIViewController {
    
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var sentimentLabel: UILabel!
    
    func updateSentimentAnalysis() {
        
        let predictionInput = self.inputTextView.text.lowercased()
        
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                let sentimentPredictor = try NLModel(mlModel: MovieReview().model)
                
                guard let sentimentPredictionOutput = sentimentPredictor.predictedLabel(for: predictionInput) else { return }
                
                let predictionIsPositive = sentimentPredictionOutput == "Pos"
                
                DispatchQueue.main.async {
                    let displayableResult = predictionIsPositive ? "positive 👍" : "negative 👎"
                    self.sentimentLabel.text = "It seems that your opinion is \(displayableResult)"
                }
            } catch {
                print(error)
            }
        }
    }
}

extension ViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        updateSentimentAnalysis()
    }
}
