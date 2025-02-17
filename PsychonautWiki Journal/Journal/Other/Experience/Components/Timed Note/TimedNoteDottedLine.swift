// Copyright (c) 2023. Isaak Hanimann.
// This file is part of PsychonautWiki Journal.
//
// PsychonautWiki Journal is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public Licence as published by
// the Free Software Foundation, either version 3 of the License, or (at 
// your option) any later version.
//
// PsychonautWiki Journal is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with PsychonautWiki Journal. If not, see https://www.gnu.org/licenses/gpl-3.0.en.html.

import SwiftUI

struct TimedNoteDottedLine: View {

    let color: Color

    var body: some View {
        Canvas { context, size in
            var path = Path()
            path.move(to: CGPoint(x: size.width/2, y: size.height))
            path.addLine(to: CGPoint(x: size.width/2, y: 0))
            context.stroke(
                path,
                with: .color(color),
                style: StrokeStyle.getTimedNoteStokeStyle())
        }
        .frame(width: StrokeStyle.timedNoteLineWidth)
    }
}

struct TimedNoteDottedLine_Previews: PreviewProvider {
    static var previews: some View {
        TimedNoteDottedLine(color: .blue)
    }
}
