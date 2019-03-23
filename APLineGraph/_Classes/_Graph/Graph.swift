//
//  Graph.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/10/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import UIKit


private extension Constants {
    static let inspectionViewTopMargin: CGFloat = 22
    static let inspectionPointSize: CGFloat = 8.66667
    static let inspectionPointImage = UIImage(named: "plot-point", in: .framework, compatibleWith: nil)
    static let inspectionPointBackgroundImage = UIImage(named: "plot-point-background", in: .framework, compatibleWith: nil)
    static let horizontalAxisOffset: CGFloat = 20
}


public final class Graph: UIView {
    
    // ******************************* MARK: - Public Properties
    
    /// - warning: Use initializer. Not everything might be updated after setting new configuration.
    public var configuration: Configuration {
        didSet {
            guard oldValue != configuration else { return }
            updateApperance(animated: true)
        }
    }
    
    /// Automatically scale graph Y axis to show full range of values
    public var autoScale: Bool = true {
        didSet {
            showRange(range: range, animated: true)
        }
    }
    
    public var onStartTouching: (() -> Void)?
    public var onStopTouching: (() -> Void)?
    
    // ******************************* MARK: - Private Properties
    
    private var previousSize: CGSize = .zero
    private var plotsShapeLayers: [Plot: CAShapeLayer] = [:]
    private var range: RelativeRange = .full
    private var horizontalAxis: HorizontalAxis?
    private var verticalAxis: VerticalAxis?
    private let inspectionView = GraphInspectionView.create()
    private var inspectionGuideViewCenterX: NSLayoutConstraint!
    private var inspectionGuideViewBottomToSuperview: NSLayoutConstraint!
    private var inspectionGuideViewBottomToAxis: NSLayoutConstraint?
    private var plotsTranslateX: CGFloat = 0
    private var plotsScaleX: CGFloat = 0
    private var plotsTransformX = CGAffineTransform.identity
    
    private var availableHeight: CGFloat {
        if configuration.showAxises {
            return bounds.height - c.horizontalAxisOffset
        } else {
            return bounds.height
        }
    }
    
    private var plotsSizeY: CGFloat {
        return availableHeight * (1 - configuration.verticalPercentGap)
    }
    
    private lazy var inspectionGuideView: UIView = {
        let view = UIView()
        view.backgroundColor = configuration.inspectionGuideColor
        view.bounds = CGRect(x: 0, y: 0, width: 1, height: availableHeight)
        view.autoresizingMask = [.flexibleHeight]
        view.widthAnchor.constraint(equalToConstant: 1).isActive = true
        
        return view
    }()
    
    private lazy var inspectionPointViewsReuseController: ReuseController<UIView> = ReuseController<UIView>(create: { [weak self] in
        let inspectionPointImageView = UIImageView(image: c.inspectionPointImage)
        let inspectionPointBackgroundImageView = UIImageView(image: c.inspectionPointBackgroundImage)
        inspectionPointBackgroundImageView.tintColor = self?.configuration.plotInspectionPointCenterColor ?? .white
        
        let inspectionPointView = UIView(frame: CGRect(x: 0, y: 0, width: c.inspectionPointSize, height: c.inspectionPointSize))
        inspectionPointView.addSubview(inspectionPointBackgroundImageView)
        inspectionPointView.addSubview(inspectionPointImageView)
        inspectionPointView.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
        
        return inspectionPointView
    }, prepareForReuse: {
        $0.removeFromSuperview()
    })
    
    // ******************************* MARK: - Initialization and Setup
    
    public init(configuration: Configuration) {
        self.configuration = configuration
        super.init(frame: UIScreen.main.bounds)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.configuration = .default
        super.init(coder: aDecoder)
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        setupProperties()
        setupInspections()
        update(animated: false)
    }
    
    private func setupProperties() {
        backgroundColor = .clear
        clipsToBounds = true
    }
    
    private func setupInspections() {
        // Inspection View
        addSubview(inspectionView)
        inspectionView.translatesAutoresizingMaskIntoConstraints = false
        inspectionView.isHidden = true
        
        inspectionView.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor).isActive = true
        rightAnchor.constraint(greaterThanOrEqualTo: inspectionView.rightAnchor).isActive = true
        inspectionView.topAnchor.constraint(equalTo: topAnchor, constant: c.inspectionViewTopMargin).isActive = true
        
        // Inspection Guide View
        addSubview(inspectionGuideView)
        inspectionGuideView.translatesAutoresizingMaskIntoConstraints = false
        inspectionGuideView.isHidden = true
        
        inspectionGuideViewBottomToSuperview = inspectionGuideView.bottomAnchor.constraint(equalTo: bottomAnchor)
        inspectionGuideViewBottomToSuperview.isActive = true
        
        inspectionGuideView.topAnchor.constraint(equalTo: inspectionView.bottomAnchor).isActive = true
        
        let centersX = inspectionGuideView.centerXAnchor.constraint(equalTo: inspectionView.centerXAnchor)
        centersX.priority = .init(rawValue: 999)
        centersX.isActive = true
        
        inspectionGuideViewCenterX = inspectionGuideView.centerXAnchor.constraint(equalTo: leftAnchor)
        inspectionGuideViewCenterX?.isActive = true
    }
    
    // ******************************* MARK: - Public Methods
    
    public func addPlot(_ plot: Plot, animated: Bool) {
        addPlot(plot, updatePlots: true, animated: animated)
        updateAxises(animated: animated)
    }
    
    public func removePlot(_ plot: Plot, animated: Bool) {
        removePlot(plot, updatePlots: true, animated: animated)
        updateAxises(animated: animated)
    }
    
    public func addPlots(_ plots: [Plot], animated: Bool) {
        plots.forEach { addPlot($0, updatePlots: false, animated: animated) }
        updatePlots(animated: false)
        updateAxises(animated: animated)
    }
    
    public func removeAllPlots(animated: Bool) {
        plotsShapeLayers.keys.forEach { removePlot($0, updatePlots: false, animated: animated) }
        updatePlots(animated: false)
        updateAxises(animated: animated)
    }
    
    // TODO: Rethink this method so it convenient for anyone to use
    public func showRange(range: RelativeRange, animated: Bool) {
        // TODO: if range size didn't change just scroll
        self.range = range
        horizontalAxis?.range = range
        verticalAxis?.range = autoScale ? range : .full
        updatePlots(animated: animated)
    }
    
    // ******************************* MARK: - Layout
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        guard previousSize != bounds.size else { return }
        previousSize = bounds.size
        layoutAxises()
        updatePlots(animated: false)
    }
    
    private func layoutAxises() {
        if let verticalAxis = verticalAxis {
            verticalAxis.frame = CGRect(x: 0, y: 0, width: bounds.width, height: availableHeight)
            sendSubviewToBack(verticalAxis)
        }
        
        if let horizontalAxis = horizontalAxis {
            let height = horizontalAxis.maxLabelSize.height
            horizontalAxis.frame = CGRect(x: 0, y: bounds.height - height, width: bounds.width, height: height)
            bringSubviewToFront(horizontalAxis)
        }
    }
    
    // ******************************* MARK: - Update
    
    private func update(animated: Bool) {
        updateAxises(animated: animated)
        updateLineLength(animated: animated)
        updatePlots(animated: animated)
    }
    
    private func updateApperance(animated: Bool) {
        inspectionPointViewsReuseController.removeAll()
        inspectionGuideView.backgroundColor = configuration.inspectionGuideColor
        updateAxises(animated: animated)
        updateLineLength(animated: animated)
        updatePlots(animated: animated)
    }
    
    private func updateAxises(animated: Bool) {
        perform(animated: animated) {
            if self.configuration.showAxises {
                guard let dates = self.plotsShapeLayers.keys.first?.points.map({ $0.date }) else { return }
                
                if let horizontalAxis = self.horizontalAxis, let verticalAxis = self.verticalAxis {
                    horizontalAxis.dates = dates
                    verticalAxis.minMaxRanges = self.getMinMaxRanges()
                    verticalAxis.configuration = self.configuration
                    
                } else {
                    let horizontalAxis = HorizontalAxis(dates: dates, configuration: self.configuration)
                    self.horizontalAxis = horizontalAxis
                    self.addSubview(horizontalAxis)
                    
                    let minMaxRanges = self.getMinMaxRanges()
                    let verticalAxis = VerticalAxis(minMaxRanges: minMaxRanges, configuration: self.configuration)
                    self.verticalAxis = verticalAxis
                    self.addSubview(verticalAxis)
                    
                    self.inspectionGuideViewBottomToAxis = self.inspectionGuideView.bottomAnchor.constraint(equalTo: horizontalAxis.topAnchor)
                    self.inspectionGuideViewBottomToAxis?.isActive = true
                    self.inspectionGuideViewBottomToSuperview.isActive = false
                }
                
                self.layoutAxises()
                
            } else {
                self.horizontalAxis?.removeFromSuperview()
                self.horizontalAxis = nil
                self.verticalAxis?.removeFromSuperview()
                self.verticalAxis = nil
            }
        }
    }
    
    private func updateLineLength(animated: Bool) {
        plotsShapeLayers.values.forEach { $0.lineWidth = configuration.lineWidth }
    }
    
    private func updatePlots(animated: Bool) {
        let width = bounds.width
        let height = self.availableHeight
        
        // Scale X
        let maxCount = plotsShapeLayers
            .keys
            .map { $0.lastIndex }
            .max() ?? 1
        
        let visibleRange = range.size
        let plotSize = CGFloat(maxCount)
        let scaleX: CGFloat = width / (plotSize * visibleRange)
        let translateX: CGFloat = -plotSize * range.from
        
        // Scale Y
        let minMaxRange = autoScale ? getMinMaxRange(range: range) : getMinMaxRange(range: .full)
        let minValue: CGFloat = minMaxRange.min
        let maxValue: CGFloat = minMaxRange.max
        
        let rangeY: CGFloat = maxValue - minValue
        let gap: CGFloat = height * configuration.verticalPercentGap
        let availableHeight: CGFloat = height - 2 * gap
        
        // Scale to show range with top and bottom paddings
        let scaleY: CGFloat = availableHeight / rangeY
        // Move graph min value onto axis
        let translateY: CGFloat = -minValue
        
        plotsTranslateX = translateX
        plotsScaleX = scaleX
        plotsTransformX = CGAffineTransform.identity
            // Move axis origin to bottom of a screen plus gap
            .translatedBy(x: 0, y: plotsSizeY)
            // Mirror over Y axis
            .scaledBy(x: 1, y: -1)
            // Scale graph by Y so it's in available range
            // Scale graph by X so it represents region length
            .scaledBy(x: scaleX, y: scaleY)
            // Apply X translation so graph on range start
            // Apply Y translation so graph is in available range
            .translatedBy(x: translateX, y: translateY)
        
        // TODO: Last thing left!
        // Calculate animation duration
        // duration is always less then Axis.animationDuration
        // duration = height change / max height in range
        
        let duration = animated ? configuration.animationDuration : 0
        plotsShapeLayers.forEach { $0.0.updatePath(shapeLayer: $0.1, translateX: translateX, scaleX: scaleX, sizeY: plotsSizeY, transform: plotsTransformX, duration: duration) }
    }
    
    // ******************************* MARK: - Inspections
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard configuration.enableInspection else { return }
        onStartTouching?()
        updateInspections(touches: touches)
        showInspections()
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard configuration.enableInspection else { return }
        updateInspections(touches: touches)
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        hideInspections()
        onStopTouching?()
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        hideInspections()
        onStopTouching?()
    }
    
    private func showInspections() {
        inspectionGuideView.isHidden = false
        
        inspectionView.isHidden = false
        bringSubviewToFront(inspectionView)
    }
    
    private func updateInspections(touches: Set<UITouch>) {
        let touchPoint = touches.first?.location(in: self) ?? .zero
        inspectionGuideViewCenterX.constant = touchPoint.x
        
        let plotsPoints: [Plot: Plot.Point] = Array(plotsShapeLayers.keys).dictionaryMap { plot in
            let point = plot.getPoint(plotTransform: plotsTransformX, point: touchPoint)
            return (plot, point)
        }
        
        inspectionPointViewsReuseController.queueAll()
        
        plotsPoints
            .map { plot, point in
                let center = plot.transform(point: point, transform: plotsTransformX)
                let inspectionPoint = inspectionPointViewsReuseController.dequeue()
                inspectionPoint.center = center
                inspectionPoint.tintColor = plot.lineColor
                inspectionPoint.alpha = 1
                return inspectionPoint
            }
            .forEach { insertSubview($0, belowSubview: inspectionView) }
        
        if let date = plotsPoints.first?.value.date {
            let vm = GraphInspectionVM(date: date, plotsPoints: plotsPoints, configuration: configuration)
            inspectionView.configure(vm: vm)
        } else {
            print("Unable to get inspection date")
        }
    }
    
    private func hideInspections() {
        inspectionGuideView.isHidden = true
        inspectionView.isHidden = true
        inspectionPointViewsReuseController.queueAll()
    }
    
    // ******************************* MARK: - Private Methods
    
    private func addPlot(_ plot: Plot, updatePlots: Bool, animated: Bool) {
        let shapeLayer = plot.createShapeLayer()
        shapeLayer.lineWidth = configuration.lineWidth
        let initialGraph = plotsShapeLayers.isEmpty
        plotsShapeLayers[plot] = shapeLayer
        layer.addSublayer(shapeLayer)
        
        if initialGraph {
            // Show graph on its position
            if updatePlots { self.updatePlots(animated: false) }
            
            // Fade in
            if animated { shapeLayer.showAnimated() }
            
        } else {
            // Layout plot according to current transform
            plot.updatePath(shapeLayer: shapeLayer, translateX: plotsTranslateX, scaleX: plotsScaleX, sizeY: plotsSizeY, transform: plotsTransformX, duration: 0)
            
            // Then fade in
            if animated { shapeLayer.showAnimated() }
            
            // Then scale all to actual size
            if updatePlots { self.updatePlots(animated: animated) }
        }
    }
    
    private func removePlot(_ plot: Plot, updatePlots: Bool, animated: Bool) {
        guard let shapeLayer = plotsShapeLayers[plot] else { return }
        
        let isLastPlot = plotsShapeLayers.count == 1
        plotsShapeLayers[plot] = nil
        
        // Fade out and remove
        if animated {
            shapeLayer.hideAnimated { shapeLayer.removeFromSuperlayer() }
        } else {
            shapeLayer.removeFromSuperlayer()
        }
        
        if !isLastPlot {
            // Calculate new transform for left plots and update them
            if updatePlots { self.updatePlots(animated: animated) }
            
            // Update removing plot with new transform
            let duration = animated ? configuration.animationDuration : 0
            plot.updatePath(shapeLayer: shapeLayer, translateX: plotsTranslateX, scaleX: plotsScaleX, sizeY: plotsSizeY, transform: plotsTransformX, duration: duration)
        }
    }
    
    // TODO: Optimize
    private func getMinMaxRange(range: RelativeRange) -> MinMaxRange {
        let minMaxes = plotsShapeLayers
            .keys
            .map { $0.getMinMaxRange(range: range) }
        
        let minValue = minMaxes
            .map { $0.min }
            .min() ?? 0
        
        let maxValue = minMaxes
            .map { $0.max }
            .max() ?? 1
        
        return MinMaxRange(min: minValue, max: maxValue)
    }
    
    private func getMinMaxRanges() -> [MinMaxRange] {
        let count = plotsShapeLayers
            .keys
            .map { $0.points.count }
            .min() ?? 0
        
        var minMaxRanges: [MinMaxRange] = []
        for i in 0..<count {
            let values = plotsShapeLayers
                .keys
                .map { $0.points[i].value }
            
            let min = values.min() ?? 0
            let max = values.max() ?? 0
            let minMaxRange = MinMaxRange(min: min, max: max)
            minMaxRanges.append(minMaxRange)
        }
        
        return minMaxRanges
    }
    
    private func perform(animated: Bool, operations: @escaping Globals.SimpleClosure) {
        let duration = animated ? configuration.animationDuration : 0
        g.animateIfNeeded(duration, animations: operations)
    }
}
