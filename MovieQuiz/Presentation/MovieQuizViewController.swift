import UIKit

final class MovieQuizViewController: UIViewController {
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
    var polsovatel : Bool = true
    
    @IBAction func yesButtonClicked(_ sender: UIButton) {
        checkAnswer(userAnswer: true)
    }
    
    @IBAction func noButtonClicked(_ sender: UIButton) {
        checkAnswer(userAnswer: false)
    }
    
    
    struct QuizQuestion {
        let image: String   // строка с названием фильма
        let text: String    // строка с вопросом о рейтинге фильма
        let correctAnswer: Bool     // правильный ответ да или нет
    }
    
    // вью модель для состояния "Вопрос показан"
    struct QuizStepViewModel {
        // картинка с афишей фильма с типом UIImage
        var image: UIImage
        // вопрос о рейтинге квиза
        let question: String
        // строка с порядковым номером этого вопроса (ex. "1/10")
        let questionNumber: String
    }
    
    private var currentQuestionIndex = 0
    private var couterAnswers = 0
    
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        show(quiz: convert(model: questions.first!))
    }
    
    
    // массив структур (вопросов)
    private let questions: [QuizQuestion] = [
        QuizQuestion(image: "The Godfather", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Dark Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Kill Bill", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Avengers", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Deadpool", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Green Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Old", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "The Ice Age Adventures of Buck Wild", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "Tesla", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "Vivarium", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false)
    ]
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        
        let image = UIImage(named: model.image) ?? UIImage() //или пустая картинка
        let question = model.text
        let questionNumber = "\(currentQuestionIndex + 1) / \(questions.count)"
        
        return QuizStepViewModel(image: image, question: question, questionNumber: questionNumber)
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func checkAnswer(userAnswer: Bool) {
        let isCorrect = questions[currentQuestionIndex].correctAnswer == userAnswer
        
        if isCorrect == true {
            couterAnswers += 1
        }
        // красим рамку
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ?
        UIColor(resource: .ypGreenIOS).cgColor :
        UIColor(resource: .ypRedIOS).cgColor
        
        //  задержка 3 секунды перед переходом к следующему вопросу
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.goToNextQuestion()
        }
    }
    
    // метод перехода к следующему вопросу
    private func goToNextQuestion() {
        currentQuestionIndex += 1
        imageView.layer.borderColor = UIColor(resource: .ypBlackIOS).cgColor
        
        //проверяем на окончание вопросов
        if currentQuestionIndex < questions.count {
            let nextQuestion = convert(model: questions[currentQuestionIndex])
            show(quiz: nextQuestion)
        } else {
            // это конец!
            showQuizFinished()
        }
    }
    
    private func showQuizFinished() {
        let alert = UIAlertController(
            title: "Раунд окончен",
            message: "Ваш результат: \(couterAnswers)/\(questions.count)",
            preferredStyle: .alert
        )
        
        // Кнопка «Повторить»
        alert.addAction(UIAlertAction(
            title: "Сыграть ещё раз",
            style: .default
        ) { _ in self.restartQuiz() })
        
        // Кнопка «Закрыть»
        alert.addAction(UIAlertAction(
            title: "Закрыть",
            style: .cancel
        ))
        
        present(alert, animated: true)
    }
    
    private func restartQuiz() {
        // 1. Сброс счётчиков
        currentQuestionIndex = 0
        couterAnswers = 0
        
        // 2. Сброс визуальных эффектов
        imageView.layer.borderWidth = 0  // убрать рамку
        imageView.layer.borderColor = UIColor.clear.cgColor
        
        
        // 3. Показать первый вопрос
        if let firstQuestion = questions.first {
            let viewModel = convert(model: firstQuestion)
            show(quiz: viewModel)
        }
    }
}



/*
 Mock-данные
 
 
 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 */
