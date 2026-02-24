//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Flymetric on 22.02.2026.
//

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}
