import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
        
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        checkAnswer(userAnswer: true)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        checkAnswer(userAnswer: false)
    }
    

    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    private let questionsAmount: Int = 10 // общее количество вопросов квиза
    private var questionFactory: QuestionFactoryProtocol? // фабрика вопросов, контроллер будет обращаться за вопросами к ней
    private var currentQuestion: QuizQuestion? // вопрос который видит пользователь
    
    private var alertPresenter = AlertPresenter()
    private var statisticService = StatisticService()

    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let questionFactory = QuestionFactory()
        questionFactory.delegate = self
        self.questionFactory = questionFactory
        
        questionFactory.requestNextQuestion() // запрос первого вопроса
        

    }
    
    // MARK: - QuestionFactoryDelegate (Делегат)
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            showError(message: "Не удалось загрузить вопрос")
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async{ [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    // вывод ошибки в виде алерта
    private func showError(message: String) {
        
//        было
//        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "Принял", style: .default))
//        present(alert, animated: true)
        
        //стало
        let model = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Принял") { } // Пусто, если ничего делать не нужно
        
        alertPresenter.show(in: self, model: model)
    }
    
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        
        let image = UIImage(named: model.image) ?? UIImage() //или пустая картинка
        let question = model.text
        let questionNumber = "\(currentQuestionIndex + 1)/\(questionFactory?.questionCount() ?? questionsAmount)"
        
        return QuizStepViewModel(image: image, question: question, questionNumber: questionNumber)
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    

    
    private func checkAnswer(userAnswer: Bool) {
        
        guard let current = currentQuestion else { return } // проверяем, что вопрос есть

        let isCorrect = current.correctAnswer == userAnswer
        
        if isCorrect == true {
            correctAnswers += 1
        }
        
        // Сохраняем прогресс после каждого ответа
//            statisticService.store(correct: correctAnswers, total: currentQuestionIndex + 1)
//            
        // красим рамку
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect
            ? UIColor(resource: .ypGreenIOS).cgColor
            : UIColor(resource: .ypRedIOS).cgColor
        
        //  задержка 3 секунды перед переходом к следующему вопросу
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.goToNextQuestion()
        }
    }
    
    // метод перехода к следующему вопросу
    private func goToNextQuestion() {
        imageView.layer.borderColor = UIColor(resource: .ypBlackIOS).cgColor
        
        //проверяем на окончание вопросов
        if currentQuestionIndex < (questionFactory?.questionCount())! - 1 {
            currentQuestionIndex += 1

            questionFactory?.requestNextQuestion() // запрашиваем следующий вопрос через фабрику
        } else {
            // это конец!
            showQuizFinished()
        }
    }
    
    
    private func showQuizFinished() {
//        было
//        let alert = UIAlertController(
//            title: "Раунд окончен",
//            message: "Ваш результат: \(correctAnswers)/\(questionFactory!.questionCount())",
//            preferredStyle: .alert
//        )
//        
//        // Кнопка «Повторить»
//        alert.addAction(UIAlertAction(
//            title: "Сыграть ещё раз",
//            style: .default
//        ) { [weak self] _ in
//            guard let self = self else {return}
//            self.restartQuiz() })
//        
//        // Кнопка «Закрыть»
//        alert.addAction(UIAlertAction(
//            title: "Закрыть",
//            style: .cancel
//        ))
//        
//        present(alert, animated: true)
        
//        стало
        guard let questionCount = questionFactory?.questionCount() else {
            showError(message: "Не получили количетво вопросов")
            return
        }
        
        let message = "Ваш результат:  \(correctAnswers)/\(questionCount)\n" +
            "Количество сыграных квизов:\(statisticService.gamesCount)\n" +
        "Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) \(statisticService.bestGame.date.dateTimeString)\n" +
            "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        let model = AlertModel(
            title: "Раунд окончен",
            message: message,
            buttonText: "Сыграть еще раз"
        ) { [weak self] in
            guard let self = self else {return}
            self.restartQuiz()
        }
        alertPresenter.show(in: self, model: model)
        
        //сохраним результаты
        statisticService.store(correct: correctAnswers, total: questionCount)
    }
    
    private func restartQuiz() {
        // 1. Сброс счётчиков
        currentQuestionIndex = 0
        correctAnswers = 0
        
        // 2. Сброс визуальных эффектов
        imageView.layer.borderWidth = 0  // убрать рамку
        imageView.layer.borderColor = UIColor.clear.cgColor
        
        
        // 3. Показать первый вопрос
        questionFactory?.requestNextQuestion()
        
    }
}




