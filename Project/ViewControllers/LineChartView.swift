import UIKit

class LineChartView: UIView {
    
    var values: [Double] = [] {
        didSet { setNeedsDisplay() }
    }
    
    var lineColor: UIColor = .systemBlue
    
    override func draw(_ rect: CGRect) {
        guard values.count > 1 else { return }
        
        let minValue = values.min()!
        let maxValue = values.max()!
        let range = max(maxValue - minValue, 0.0001)
        
        let path = UIBezierPath()
        let stepX = rect.width / CGFloat(values.count - 1)
        
        for (i, v) in values.enumerated() {
            let x = CGFloat(i) * stepX
            let y = rect.height - CGFloat((v - minValue) / range) * rect.height
            if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
            else     { path.addLine(to: CGPoint(x: x, y: y)) }
        }
        
        lineColor.setStroke()
        path.lineWidth = 2
        path.stroke()
        
        let fill = path.copy() as! UIBezierPath
        fill.addLine(to: CGPoint(x: rect.width, y: rect.height))
        fill.addLine(to: CGPoint(x: 0, y: rect.height))
        fill.close()
        lineColor.withAlphaComponent(0.15).setFill()
        fill.fill()
    }
}
